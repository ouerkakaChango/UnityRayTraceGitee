using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MathHelper.XMathFunc;

namespace Spline
{
    public enum CheapSplineType
    {
        XZ,
        XY,
        YZ,
    }

    //2D上的二次插值样条线
    public class CheapSpline : MonoBehaviour
    {
        public List<Vector3> keyPnts;
        public CheapSplineType type = CheapSplineType.XZ;
        // Start is called before the first frame update
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {

        }

        //################
        public float SDF(Vector3 p)
        {
            return -1;
        }

        //https://blog.csdn.net/zl908760230/article/details/53967828
        public Vector3 GetPnt(float t)
        {
            if(keyPnts.Count<3)
            {
                //???
                return new Vector3(0, 0, 0);
            }
            if(type == CheapSplineType.XZ)
            {
                float unit = 1.0f / (keyPnts.Count-1);
                float twounit = 2.0f * unit;
                if(t<unit)
                {//头
                    float t_local = t / twounit;
                    return GetPntXZ(t_local, 0);
                }
                else if (t>1-unit)
                {//尾
                    int segNum = keyPnts.Count - 2;
                    float t_local = (1 - t) / twounit;
                    t_local = 1 - t_local;
                    return GetPntXZ(t_local, segNum - 1);
                }
                else
                {//中间
                    int key2Inx = (int)(t / unit);
                    float residue = t - unit * key2Inx;
                    float t_local1 = 0.5f + residue / twounit;
                    var p1 = GetPntXZ(t_local1, key2Inx - 1);
                    float t_local2 = residue / twounit;
                    var p2 = GetPntXZ(t_local2, key2Inx);
                    float lerpK = residue / unit;
                    return Vector3.Lerp(p1, p2, lerpK);
                }
                
            }
            return new Vector3(0, 0, 0);
        }

        Vector3 GetPntXZ(float t, int segInx)
        {
            Vector3 p1 = keyPnts[segInx];
            float x1 = p1.x;
            float y1 = p1.z;

            Vector3 p2 = keyPnts[segInx + 1];
            float x2 = p2.x;
            float y2 = p2.z;

            Vector3 p3 = keyPnts[segInx + 2];
            float x3 = p3.x;
            float y3 = p3.z;

            Vector3 v = new Vector3(
                2*t*t-3*t+1,
                -4*t*t+4*t,
                2*t*t-t
                );

            float xp = dot(v, new Vector3(x1,x2,x3));
            float zp = dot(v, new Vector3(y1, y2, y3));
            return new Vector3(xp, p1.y, zp);
        }
    }

}
