#!/bin/env python
# coding: UTF-8

# Copyright(c) 2015-2018 Uptime Technologies, LLC.

class ConnectionError(Exception):
    def __init__(self, message):
        self.message = 'Connection Error: ' + message

    def __str__(self):
        return self.message
