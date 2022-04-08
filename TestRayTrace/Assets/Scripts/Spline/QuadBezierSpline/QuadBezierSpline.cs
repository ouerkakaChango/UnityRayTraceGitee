using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MathHelper.XMathFunc;

//每3个点一段QuadBezierSeg
//为保证Spline光滑，共线关系为:p0p1-p1p2p3-p3p4p5-...
//偶数点在spline上，奇数点不在;除了p1,奇数点根据共线关系确定位置
//除了p1可以指定任意位置，其他都是偶数p Vector2，奇数p 正float设置控制点p的位置

//Spine: p0p1p2-n*(p[2k+1]p[2k+2]) 

namespace Spline
{
    [System.Serializable]
    public struct QuadBezierSegSet
    {
        public float len;
        public Vector2 p2;
    }

    public struct QuadBezierSeg
    {
        public Vector2 p0,p1,p2;
    }

    public class QuadBezierSpline : MonoBehaviour
    {
        public Vector2 pnt0, pnt1, pnt2;
        public List<QuadBezierSegSet> segSettings = new List<QuadBezierSegSet>(); //p3p4-p5p6-...
        [HideInInspector]
        public List<Vector2> mids = new List<Vector2>(); //p3,p5...

        // Start is called before the first frame update
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {

        }

        void OnValidate()
        {
            Init();
        }

        //#########################################

        public int GetSegNum()
        {
            return segSettings.Count + 1;
        }

        public void Init()
        {
            mids.Clear();
            //p1 = dir(前p1p2)*len
            for(int i=0;i<segSettings.Count;i++)
            {
                Vector2 fp1, fp2;
                if(i==0)
                {
                    fp1 = pnt1;
                    fp2 = pnt2;
                }
                else
                {
                    fp1 = mids[i - 1];
                    fp2 = segSettings[i].p2;
                }

                mids.Add( fp2 + (fp2 - fp1).normalized * segSettings[i].len );
            }
        }

        public Vector2 Get(float globalT)
        {
            float unit = 1 / (1 + segSettings.Count);
            int segInx = (int)(globalT / unit);
            float localT = (globalT - segInx * unit) / unit;

            return Get(segInx, localT);
        }

        //https://en.wikipedia.org/wiki/B%C3%A9zier_curve
        public Vector2 Get(int segInx, float t)
        {
            Vector2 p0, p1, p2;
            GetSegPoints(segInx, out p0, out p1, out p2);
            return (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2;
        }

        public void GetSegPoints(int segInx, out Vector2 p0, out Vector2 p1, out Vector2 p2)
        {
            p0 = Vector2.zero;
            p1 = Vector2.zero;
            p2 = Vector2.zero;
            if (segInx == 0)
            {
                p0 = pnt0;
                p1 = pnt1;
                p2 = pnt2;
            }
            else if(segInx>=1+segSettings.Count)
            {
                Debug.LogError("segInx out of Range");
            }
            else if (segInx<0)
            {
                Debug.LogError("segInx < 0");
            }
            else
            {
                //p0是前一seg的p2，p1从mid中已经计算，p2从settings
                if (segInx == 1)
                {
                    p0 = pnt2;
                }
                else
                {
                    p0 = segSettings[segInx - 2].p2;
                }
                p1 = mids[segInx - 1];
                p2 = segSettings[segInx-1].p2;
            }
        }
    }
}
