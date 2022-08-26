import sys
import os


CONF_PATH = os.path.dirname(os.path.abspath(__file__))

# load configs
conf = open(os.path.join(os.path.join(CONF_PATH), "cluster.conf"), "r")
conf_dict = {"NUM_ZKSERVERS": 0, "NUM_NAMENODES": 0, "NUM_RESOURCEMANAGERS": 0, "NUM_DATANODES": 0, "NUM_NODEMANAGERS": 0}
line = conf.readline()
while line:
    if line[0] == '#' or line[0] == '\n':
        line = conf.readline()
        continue
    line = line.strip()
    key, val = line.split('=')
    key, val = key.strip(), val.strip()
    conf_dict[key] = int(val)    
    line = conf.readline()

DOCKER_PATH = os.path.join(CONF_PATH, "../docker")
SSH_PATH = os.path.join(CONF_PATH, "ssh")

sys.stdout = open(os.path.join(DOCKER_PATH, "docker-compose.yml"), "w")
print("version: \"3\"\nservices:")
# gen zk servers
zoo_servers = " ".join([f"server.{i + 1}=zk{i + 1}:2888:3888;2181" for i in range(conf_dict["NUM_ZKSERVERS"])])
for i in range(1, conf_dict["NUM_ZKSERVERS"] + 1):
    print(f"""
  zk{i}:
    image: zookeeper:3.5.6
    container_name: zk{i}
    hostname: zk{i}
    restart: always
    environment:
      ZOO_MY_ID: {i}
      ZOO_SERVERS: {zoo_servers}
    env_file:
      - ./zookeeper.env   
    """)

# gen namenodes
other_nn = " ".join([f"nn{k}" for k in range(2, conf_dict["NUM_NAMENODES"] + 1)])
for i in range(1, conf_dict["NUM_NAMENODES"] + 1):
    print(f"""
  nn{i}:
    image: hdfs/namenode
    container_name: nn{i}
    hostname: nn{i}
    restart: always
    environment:
      NN_ID: {i}
      {"OTHER_NN: " + other_nn if i == 1 else ""}
    # volumes:
    #   - ../runData/nn{i}/:/usr/local/hadoop/data/
    ports:
       - {9870 + i - 1}:9870
          """)

# gen resource manager
for i in range(1, conf_dict["NUM_RESOURCEMANAGERS"] + 1):
    print(f"""
  rm{i}:
    image: yarn/resourcemanager
    container_name: rm{i}
    hostname: rm{i}
    restart: always
    ports:
      - {8088 + i - 1}:8088
      - {8042 + i - 1}:8042
          """)

# gen datanodes
namenodes = " ".join([f"nn{i}" for i in range(1, conf_dict["NUM_NAMENODES"] + 1)])
for i in range(1, conf_dict["NUM_DATANODES"] + 1):
    print(f"""
  dn{i}:
    image: hdfs/datanode
    container_name: dn{i}
    hostname: dn{i}
    restart: always
    environment:
      {"DN_ID: 1" if i == 1 else ""}
      NAMENODES: {namenodes}
    {"volumes:" if i == 1 else ""}
      {"- ../exchange/data:/data  # use for exchange data from host machine to container" if i == 1 else ""}
      # - ../runData/dn{i}/:/usr/local/hadoop/data/
          """)
    
# gen nodemanager
resourcemanagers = " ".join([f"rm{i}" for i in range(1, conf_dict["NUM_RESOURCEMANAGERS"] + 1)])
for i in range(1, conf_dict["NUM_NODEMANAGERS"] + 1):
      print(f"""
  nm{i}:
    image: yarn/nodemanager
    container_name: nm{i}
    hostname: nm{i}
    restart: always
    environment:
      RESOURCEMANAGERS: {resourcemanagers}
    deploy:
      resources:
          limits:
            cpus: "2.00"
            memory: 5G
    """)

# gen spark client
print(f"""
  sc:
    image: env/sparkclient
    container_name: sc
    hostname: sc
    restart: always
    volumes:
      - ../exchange/code:/jars
    """)

# gen network
print(f"""
networks:
  default:
    driver: bridge
      """)
sys.stdout.close()


sys.stdout = open(os.path.join(SSH_PATH, "ssh_config"), "w")
# nn dn and rm needs to be added
points = [f"nn{i + 1}" for i in range(conf_dict["NUM_NAMENODES"])] + \
        [f"dn{i + 1}" for i in range(conf_dict["NUM_DATANODES"])] + \
        [f"rm{i + 1}" for i in range(conf_dict["NUM_RESOURCEMANAGERS"])]
for point in points:
    print(f"""
Host {point}
  HostName {point}
  User root
  IdentityFile "/root/.ssh/ssh_host_ecdsa_key"
          """)
sys.stdout.close()
