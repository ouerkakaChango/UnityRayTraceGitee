using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace AlgorithmHelper
{
    public static class AlgoHelper
    {
        public static int GetTreeDepth(int inx, int maxDepth)
        {
            //depht = 2,  >=2^2-1, <=2^3-2
            for (int i = 0; i <= maxDepth; i++)
            {
                int up = (int)Mathf.Pow(2, i + 1) - 2;
                if (inx < up)
                {
                    return i;
                }
            }
            return -1;
        }
    }
}
