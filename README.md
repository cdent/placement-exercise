
From the comments in placement_exercise.sh

```
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
```

See [the generic resource pools
spec](http://specs.openstack.org/openstack/nova-specs/specs/newton/approved/generic-resource-pools.html)
for more context.
