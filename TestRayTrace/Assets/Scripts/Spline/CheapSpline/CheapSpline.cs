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
            if(type == CheapSplineType.XZ)
            {
                //???
                int segInx1 = 0;
                return GetPntXZ(t, segInx1);
            }
            return new Vector3(0, 0, 0);
        }

        Vector3 GetPntXZ(float t, int segInx)
        {
            Vector3 p1 = keyPnts[3*segInx];
            float x1 = p1.x;
            float y1 = p1.z;

            Vector3 p2 = keyPnts[3*segInx + 1];
            float x2 = p2.x;
            float y2 = p2.z;

            Vector3 p3 = keyPnts[3*segInx + 2];
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
