using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MathHelper.XMathFunc;

namespace ShaderEqualision
{
    public static class RayMathFuncs
    {
        public static bool IsInBBox(in Vector3 pos, in Vector3 boxMin, in Vector3 boxMax)
        {
            return gt(pos, boxMin) && lt(pos, boxMax);
        }
    }

}