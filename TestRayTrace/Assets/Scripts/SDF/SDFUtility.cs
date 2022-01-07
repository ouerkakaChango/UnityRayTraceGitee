using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FastGeo;

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
    };
}
