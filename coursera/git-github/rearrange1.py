#!/usr/bin/env python3
import re

def rearrange_name(name):
    pattern = r"^([\w.]*),([\w.]*)$"
    result = re.search(pattern, name)

    if result is None:
        return name

    return f"{result[2]} {result[1]}"
