using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FastGeo;
using MathHelper;
using static MathHelper.XMathFunc;

namespace SDFUtility
{
    public class SDFShape
    {
        public virtual float GetRadiusInDir(Vector3 dir)
        {
            return 0;
        }
    };

    public class SDFSphere : SDFShape
    {
        public float r;
        public SDFSphere(float r_)
        {
            r = r_;
        }

        public override float GetRadiusInDir(Vector3 dir)
        {
            return r;
        }
    };

    public static class SDFMath
    {
        public static float SDFSphere(Vector3 p, Vector3 center, float r)
        {
            return (p - center).magnitude - r;
        }

        public static Vector3 SDFSphereNormal(Vector3 p, Vector3 center)
        {
            return normalize(p - center);
        }

        public static float SDFBox(Vector3 p, Vector3 center, Vector3 bound)
        {
            Vector3 q = abs(p - center) - bound;
            return length(max(q, 0.0f)) + min(max(q.x, max(q.y, q.z)), 0.0f);
        }
    };
}
