#!/bin/env python
# coding: UTF-8

# log
#
# Copyright(c) 2015 Uptime Technologies, LLC.

import logging

logging.basicConfig(format='[%(asctime)s] %(levelname)s: %(message)s',
                    datefmt="%Y-%m-%d %H:%M:%S")
logger = logging.getLogger('PsqlWrapper')
logger.setLevel(logging.INFO)

INFO = logging.INFO
DEBUG = logging.DEBUG

def setLevel(level):
    logger.setLevel(level)

def debug(msg):
    logger.debug(msg)

def error(msg):
    logger.error(msg)

def warning(msg):
    logger.warning(msg)

def info(msg):
    logger.info(msg)
