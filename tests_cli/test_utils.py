import re
import subprocess


def execute(command, stdin_data=None):
    args = re.split(' +', command)

    stdin_param = None
    if stdin_data:
        stdin_param = subprocess.PIPE

    p = subprocess.Popen(args,
                         stdin=stdin_param,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    stdout_data, stderr_data = p.communicate(stdin_data)

    return (p.returncode, stdout_data, stderr_data)


def wc(s):
    return len(s.split('\n'))


def grep(s, pattern):
    res = []
    for l in s.split('\n'):
        if re.search(pattern, l):
            res.append(l)
    return res


