#!/usr/bin/env python3
from itertools import combinations

class Solution(object):
    def maximumGap(self, nums):
        """
        :type nums: List[int]
        :rtype: int
        """
        if len(nums) < 2:
            return 0

        s_nums = sorted(nums)
        l_nums =  [(s_nums[i], s_nums[i+1]) for i in range(len(s_nums)) if i < (len(s_nums) - 1)]

        return max([abs(a-b) for a, b in l_nums])



if __name__ == '__main__':
    nums = [3, 6, 9, 1]

    s = Solution()
    print(s.maximumGap(nums))
