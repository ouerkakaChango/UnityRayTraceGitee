using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Debugger;

namespace PointCloudHelper
{
    public static class PCL
    {
        static public float MAXFloat = 100000.0f;

        static void CheckMinMax(in Vector3 p, ref Vector3 min, ref Vector3 max)
        {
            if (p.x < min.x)
            {
                min.x = p.x;
            }
            if (p.y < min.y)
            {
                min.y = p.y;
            }
            if (p.z < min.z)
            {
                min.z = p.z;
            }

            if (p.x > max.x)
            {
                max.x = p.x;
            }
            if (p.y > max.y)
            {
                max.y = p.y;
            }
            if (p.z > max.z)
            {
                max.z = p.z;
            }
        }

        public static Bounds GetBounds(in Vector3[] pnts)
        {
            //遍历，设置bbox的minmax X,Y,Z (2个float3)
            Vector3 min = Vector3.one * MAXFloat;
            Vector3 max = -Vector3.one * MAXFloat;

            for (int i = 0; i < pnts.Length; i++)
            {
                CheckMinMax(pnts[i], ref min, ref max);
            }
            Bounds re = new Bounds();
            re.min = min;
            re.max = max;
            return re;
        }
    }
}
