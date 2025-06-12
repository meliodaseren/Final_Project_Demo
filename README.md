## Topology

**AS65000 (SDN netword)**
* 2 個 web container
* 2 個 ovs 分別為 ovs1 與 ovs2
* ovs1
  * 連接至 1 個 web container
  * 連接至 AS65020 的 FRR container
  * 連接至 ovs2
* ovs2
  * 連接至 1 個 web container
  * 連接至 BGP speaker (FRRouting)
  * 連接至 ovs1、連接至 AS65010 的 FRR container
  * 連接至 AS65021 的 FRR container

**AS65010 (Peer)**
* 1 個 web container
* 1 個 FRR container
  * 連接到 web container
  * 連接到 AS65021 的 FRR container
  * 連接到 ovs2

**AS65020 (WAN)**
* 1 個 web container
* 1 個 FRR container
  * 連接到 web container
  * 連接到 ovs1

**AS65021 (WAN)**
* 1 個 web container
* 1 個 FRR container
  * 連接到 web container
  * 連接到 AS65010 的 FRR container
  * 連接到 ovs2

---

## Project Information and Installation

### Configuration Requirements

* Networks
  * AS65000 192.168.0.0/24
  * AS65010 10.0.0.0/24
  * AS65020 10.1.0.0/24
  * AS65021 10.2.0.0/24
* AS65000 only advertise its own prefix 192.168.0.0/24 to its peers (AS65010)
* SDN Network will advertise prefixes received from WAN to WANs or peers
* BGP Speaker can set as gateway IP
* Web container IP in AS 65000 must be the same
* Container images
  * FRR container frrouting frr Debian
  * Web container traefik whoami

```sh
docker ps -a
```

---

### vRouter Verifications - Router Communication

Assure Router Communication

* Each FRRouting can ping it’s neighbors
  * For Non-SDN Network, directly connect -> easy
  * For SDN Network, not directly connect -> what to do?
* Hint: What IP should you assign?
  * L2 traffic doesn’t need routing, i.e. IP information
* Expected results
  * `show routes` in FRR looks right
  * `routes` in ONOS looks right

---

### vRouter Verifications – Intra Domain Traffic

Assure Intra domain traffics

* BGP speaker in AS65000 can ping Web server vice versa
  * There are multiple ways to achieve
  * IP should be within 192.168.0.0/24
* traefik/whoami does not have a shell how to ping?
  * `ip netns exec …`

---

### vRouter Verifications – Inter Domain Traffic

Assure Inter domain traffics

* Must add flow rules to OVS
  * `routes` in ONOS
* Hint
  * Gateway in none-SDN network
    * set via `ip route add…`
  * Gateway in SDN Network
    * any difference?
* Expected results
  * AS65021 web container can ping AS65000 web container vice versa
  * Use mtr (traceroute tool) will see packets from
    * AS65021 FRRouting IP -> AS65000 Web Container
    * No AS65000 FRRouting IP showed in mtr

NOTE: If you are using docker compose, it will automatically assign a gateway for the container which is often not what you want, remember to `ip route delete …`

---

### vRouter Verifications – Inter Domain Traffic (cont.)

Assure Inter domain traffics

* More flow rules to OVS
* Hint
  * Gateway in none-SDN network
    * set via `ip route add…`
  * Gateway in SDN Network
    * any difference?
* Expected results
  * Web containers in AS650xx can ping AS65000 web container vice versa
  * Use mtr (traceroute tool) will see packets does not pass AS65000 BGP Speaker

---

### vRouter Verifications – Transit Traffic

Assure transit traffics

* Flow rules to OVS
* Hint
  * Think how routers works
  * Compare types of traffic
    * What are the same?
    * How to determine which type of traffic?
    * Can some traffics merge in to one flow rule?
* Expected results
  * Web containers in AS65021 can ping AS65020 web container vice versa
  * Use mtr (traceroute tool) will see packets does not pass AS65000 BGP Speaker
    * AS65021 FRR <-> AS65020 FRR <-> AS65020 Web Container

---

### Requirement Verifications – Peers

Requirement

* AS65000 only advertise its own prefix (192.168.0.0/24) to its peers (AS65010)
  * AS65010 FRR will not receive AS65020’s prefix from AS65000
* Hint:
  * AS65010 FRR will receive AS65020’s prefix from AS65021
  * Packet path from AS65010 Web container to AS65020 Web container?
  * Packet path from AS65010 Web container to AS65000 Web container?
* Expect Results
  * mtr ?????

---

### Requirement Verifications – Anycast Web Container

Requirement

* Web container IP in AS65000 must be the same
* Why?
  * OVS1 and OVS2 might be in different physical zone (America vs Taiwan)
  * OVS1 and OVS2 have very high latency
  * AS65021 can get data from OVS2 Web Container
  * AS65020 can get data from OVS1 Web Container
* Expected Result
  * AS65021 curl Web Container IP
    * Hostname: xxxxxxxx
  * AS65020 curl Web Container IP
    * Hostname: yyyyyyyy

---

### Requirement Verifications – Anycast Hints

Requirement

* Web container IP in AS65000 must be the same
* Hints:
  * After adding the new Web container, many things might be destroyed
  * Use wireshark/tcpdump to check one by one from Step 1. again
    * Why things get weird? How to fix?
    * Mostly, block packets that is not expected

---

### TA Hints

DEMO part

* Requires network knowledge and SDN knowledge
* Steps to solve a problem
  1. Think what is the expect result
  2. Think what shall be done to achieve the expect result
    * Separate tasks into small achievements
  3. Verify if the result met the expected result
* Wireshark and tcpdump (if you are familiar with Linux cli) is good
* Make sure you know MAC and IP value
  * Enters/Leaves the router
  * How it is decided
* Flow priority is important remember to check
* Docker compose will auto assign a gateway, this might not be what you want!!!!

---

### Deployment Requirements

* Only openflow (and route related apps can be use
* Cannot use Reactive forwarding (org.onosproject.fwd)

---

### Scores

**Code (60 points)**

* Intra domain traffic (from both AS)
  * IPv4 (20 points)
* Inter domain traffic (from both AS)
  * IPv4 (20 points)
* Transit traffic
  * IPv4 (15 points)
* Routes in ONOS `routes` and FRR `show bgp routes` correct
  * IPv4 (5 points)

**Demo (40 points)**

* Peers traffic (10 points explanation + 10 points verification)
* Anycast traffic (10 points explanation + 10 points verification)
