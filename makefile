.PHONY: all clean test

all:
	@echo "docker compose up -d"
	docker compose up -d
	sleep 5
	@docker ps

	@echo "create OVC ..."
	sudo ovs-vsctl add-br ovs1
	sudo ovs-vsctl add-br ovs2

	@echo "create NIC ..."
	sudo ip link add veth-ovs1 type veth peer name veth-ovs2
	sudo ovs-vsctl add-port ovs1 veth-ovs1
	sudo ovs-vsctl add-port ovs2 veth-ovs2
	sudo ip link set veth-ovs1 up
	sudo ip link set veth-ovs2 up

	@PID=$$(docker inspect -f '{{.State.Pid}}' $$(docker ps -aqf "name=web65000")); \
	echo "web65000 PID: $$PID"; \
	sudo ln -sf /proc/$$PID/ns/net /var/run/netns/$$PID; \
	sudo ip link add vethWeb65000Ovs type veth peer name vethOvsWeb65000; \
	sudo ip link set vethWeb65000Ovs netns $$PID; \
	sudo ip netns exec $$PID ip addr add 192.168.0.100/24 dev vethWeb65000Ovs; \
	sudo ip netns exec $$PID ip link set vethWeb65000Ovs up; \
	sudo ip netns exec $$PID ip link set dev vethWeb65000Ovs address 02:42:c0:a8:00:64; \
	sudo ovs-vsctl add-port ovs2 vethOvsWeb65000; \
	sudo ip link set vethOvsWeb65000 up

	@PID=$$(docker inspect -f '{{.State.Pid}}' $$(docker ps -aqf "name=bgp-speaker")); \
	echo "bgp-speaker PID: $$PID"; \
	sudo ln -sf /proc/$$PID/ns/net /var/run/netns/$$PID; \
	sudo ip link add vethSpeakerOvs type veth peer name vethOvsSpeaker; \
	sudo ip link set vethSpeakerOvs netns $$PID; \
	sudo ip netns exec $$PID ip addr add 192.168.0.2/24 dev vethSpeakerOvs; \
	sudo ip netns exec $$PID ip addr add 172.20.0.3/24 dev vethSpeakerOvs; \
	sudo ip netns exec $$PID ip link set vethSpeakerOvs up; \
	sudo ip netns exec $$PID ip link set dev vethR65010Ovs address 05:42:c8:a8:00:60; \
	sudo ovs-vsctl add-port ovs2 vethOvsSpeaker; \
	sudo ip link set vethOvsSpeaker up

	@PID=$$(docker inspect -f '{{.State.Pid}}' $$(docker ps -aqf "name=r65010")); \
	echo "r65010 PID: $$PID"; \
	sudo ln -sf /proc/$$PID/ns/net /var/run/netns/$$PID; \
	sudo ip link add vethR65010Ovs type veth peer name vethOvsR65010; \
	sudo ip link set vethR65010Ovs netns $$PID; \
	sudo ip netns exec $$PID ip addr add 172.20.0.4/24 dev vethR65010Ovs; \
	sudo ip netns exec $$PID ip link set vethR65010Ovs up; \
	sudo ip netns exec $$PID ip link set dev vethR65010Ovs address 04:42:c8:a8:00:66; \
	sudo ovs-vsctl add-port ovs2 vethOvsR65010; \
	sudo ip link set vethOvsR65010 up

	@PID=$$(docker inspect -f '{{.State.Pid}}' $$(docker ps -aqf "name=r65021")); \
	echo "r65021 PID: $$PID"; \
	sudo ln -sf /proc/$$PID/ns/net /var/run/netns/$$PID; \
	sudo ip link add vethR65021Ovs type veth peer name vethOvsR65021; \
	sudo ip link set vethR65021Ovs netns $$PID; \
	sudo ip netns exec $$PID ip addr add 172.20.0.5/24 dev vethR65021Ovs; \
	sudo ip netns exec $$PID ip link set vethR65021Ovs up; \
	sudo ip netns exec $$PID ip link set dev vethR65021Ovs address 02:42:c0:a8:00:67; \
	sudo ovs-vsctl add-port ovs2 vethOvsR65021; \
	sudo ip link set vethOvsR65021 up

	@PID=$$(docker inspect -f '{{.State.Pid}}' $$(docker ps -aqf "name=r65020")); \
	echo "r65020 PID: $$PID"; \
	sudo ln -sf /proc/$$PID/ns/net /var/run/netns/$$PID; \
	sudo ip link add vethR65020Ovs type veth peer name vethOvsR65020; \
	sudo ip link set vethR65020Ovs netns $$PID; \
	sudo ip netns exec $$PID ip addr add 172.20.0.6/24 dev vethR65020Ovs; \
	sudo ip netns exec $$PID ip link set vethR65020Ovs up; \
	sudo ip netns exec $$PID ip link set dev vethR65020Ovs address 02:42:c0:a8:00:68; \
	sudo ovs-vsctl add-port ovs1 vethOvsR65020; \
	sudo ip link set vethOvsR65020 up

	@PID=$$(docker inspect -f '{{.State.Pid}}' $$(docker ps -aqf "name=web65000")); \
	echo "web65000 PID: $$PID"; \
	sudo ln -sf /proc/$$PID/ns/net /var/run/netns/$$PID; \
	sudo ip netns exec $$PID ip route del default; \
	sudo ip netns exec $$PID ip route add default via 192.168.0.2

	@PID=$$(docker inspect -f '{{.State.Pid}}' $$(docker ps -aqf "name=web65010")); \
	echo "web65010 PID: $$PID"; \
	sudo ln -sf /proc/$$PID/ns/net /var/run/netns/$$PID; \
	sudo ip netns exec $$PID ip route del default; \
	sudo ip netns exec $$PID ip route add default via 10.0.0.2

	@PID=$$(docker inspect -f '{{.State.Pid}}' $$(docker ps -aqf "name=web65021")); \
	echo "web65021 PID: $$PID"; \
	sudo ln -sf /proc/$$PID/ns/net /var/run/netns/$$PID; \
	sudo ip netns exec $$PID ip route del default; \
	sudo ip netns exec $$PID ip route add default via 10.2.0.2

	@PID=$$(docker inspect -f '{{.State.Pid}}' $$(docker ps -aqf "name=web65020")); \
	echo "web65020 PID: $$PID"; \
	sudo ln -sf /proc/$$PID/ns/net /var/run/netns/$$PID; \
	sudo ip netns exec $$PID ip route del default; \
	sudo ip netns exec $$PID ip route add default via 10.1.0.2

	# DPID
	sudo ovs-vsctl set bridge ovs1 other-config:datapath-id=0000000000000001
	sudo ovs-vsctl set bridge ovs2 other-config:datapath-id=0000000000000002

	# OpenFlow 14
	sudo ovs-vsctl set bridge ovs1 protocols=OpenFlow14
	sudo ovs-vsctl set bridge ovs2 protocols=OpenFlow14

	# ONOS controller
	sudo ovs-vsctl set-controller ovs1 tcp:172.20.0.100:6653
	sudo ovs-vsctl set-controller ovs2 tcp:172.20.0.100:6653

	sleep 30

	@echo "install flow rule ..."
	chmod 755 install_flow_rule.sh
	./install_flow_rule.sh

clean:

	@echo "docker compose down ..."
	docker compose down
	# docker compose down -v --remove-orphans
	docker network prune -f

	@echo "delete OVS bridge ovs ..."
	sudo ovs-vsctl --if-exists del-br ovs1
	sudo ovs-vsctl --if-exists del-br ovs2

	@echo "delete NIC ..."
	@sudo ip link delete veth-ovs1 || true
	@sudo ip link delete veth-ovs2 || true

	@sudo ip link delete vethWeb65000Ovs || true
	@sudo ip link delete vethOvsWeb65000 || true

	@sudo ip link delete vethSpeakerOvs || true
	@sudo ip link delete vethOvsSpeaker || true

	@sudo ip link delete vethR65010Ovs || true
	@sudo ip link delete vethOvsR65010 || true

	@sudo ip link delete vethR65021Ovs || true
	@sudo ip link delete vethOvsR65021 || true

	@sudo ip link delete vethR65020Ovs || true
	@sudo ip link delete vethOvsR65020 || true

test:

	chmod 755 network_test.sh
	./network_test.sh
	chmod 755 ping_test.sh
	./ping_test.sh
