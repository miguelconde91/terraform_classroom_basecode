#!/bin/bash

# ECS config
{
  echo "ECS_CLUSTER=${ecs_cluster}"
  echo "ECS_INSTANCE_ATTRIBUTES={\"Classroom\":\"True\"}"
} >> /etc/ecs/ecs.config

start ecs

echo "Done"