#!/bin/bash -e
# can't -u because of stuff within openrc

# Run several gabbits against a single-node devstack with the
# placmenet-api enabled to confirm that allocations are being
# written by the resource tracker.
#
# A server is created, resized, deleted. At each stage the usages
# are checked to see that they are appropriate, according to the
# flavor used. The flavors and images are those that come in a
# default devstack.
#
# You will need 'gabbi' to make this work. To get that:
#
#     pip install -U gabbi
#
# To use this:
# 
# In devstack's local.conf add 'enable_service placement-api', 
# do a ./stach.sh and then (after swearing at the screen):
#
#     source PATH_TO_DEVSTACK/openrc admin admin
#     ./placement_exercise.sh
#

# our keystone token
export TOKEN=$(openstack token issue -f value -c id)

# the name of the compute node resource provider
export RP_NAME=$(openstack compute service list --service nova-compute -f value -c Host)

# the placement endpoint
PLACEMENT_API=$(openstack endpoint show placement -f value -c publicurl)

# the compute service endpoint
export COMPUTE_API=$(openstack endpoint show compute -f value -c publicurl)

# the name of the server we create
SERVER_NAME=x1
# the image we boot
IMAGE_NAME=cirros-0.3.4-x86_64-uec
# the flavor we start with
FLAVOR1=cirros256
# the flavor we grow to
FLAVOR2=m1.tiny

# For now we scrub off the placement prefix because of
# https://github.com/cdent/gabbi/issues/165
PLACEMENT_API=${PLACEMENT_API%%/placement}


# clean ourselves up when we exit if we fail
function cleanup {
   # may fail because it was never there or already deleted
   openstack server delete $SERVER_NAME
}
trap cleanup EXIT

# Check that we have some inventory and the expected 0 usage.
gabbi-run $PLACEMENT_API < check_base.yaml

# Create one server
echo "Creating $SERVER_NAME as $FLAVOR1"
export SERVER_UUID=$(openstack server create -f value -c id --image $IMAGE_NAME --flavor $FLAVOR1 $SERVER_NAME)

# Check that we have usage
gabbi-run $PLACEMENT_API < check_vm_started.yaml

# Resize that server
echo "Resizing $SERVER_NAME to $FLAVOR2"
openstack server resize --flavor $FLAVOR2 --wait $SERVER_NAME

# Check that usage change is recorded
gabbi-run $PLACEMENT_API < check_vm_resized.yaml

# Delete the server
echo "Deleting $SERVER_NAME"
openstack server delete $SERVER_NAME

# Check that allocations were remeoved
gabbi-run $PLACEMENT_API < check_vm_deleted.yaml
