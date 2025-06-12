#!/bin/bash

# install ovs1 flue rule
for rule in r65020_to_ovs1.json ovs1_to_r65020.json ovs1_in1_out2.json ; do
    curl -u onos:rocks -X POST -H 'Content-Type: application/json' \
        -d @flowrule/ovs1/$rule http://localhost:8181/onos/v1/flows/of:0000000000000001
done

# install ovs2 flue rule
for rule in ovs2_rule1.json ovs2_rule2.json ovs2_rule3.json ovs2_rule4.json ovs2_rule5.json \
    ovs2_to_r65010.json ovs2_to_r65021.json ovs2_to_speaker.json ovs2_to_web65000.json \
    speaker_to_ovs2.json web65000_to_ovs2.json ovs2_to_r65020.json \
    web65000_to_r65021.json web65021_to_web65000.json \
    ovs2_in1_out2.json ovs2_in2_out4.json ovs2_in4_out2.json ; do
    curl -u onos:rocks -X POST -H 'Content-Type: application/json' \
        -d @flowrule/ovs2/$rule http://localhost:8181/onos/v1/flows/of:0000000000000002
done

# testing
curl -u onos:rocks -X POST -H 'Content-Type: application/json' \
    -d @flowrule/test.json http://localhost:8181/onos/v1/flows/of:0000000000000002
