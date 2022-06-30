using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MathHelper.XMathFunc;
using static MathHelper.Vec;

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

        public SpineShapeType shape = SpineShapeType.Boxed;
        [HideInInspector]
        public Vector2 boxShapeSize = new Vector2(0.1f,0.05f);

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
                    fp2 = segSettings[i-1].p2;
                }

                mids.Add( fp2 + (fp2 - fp1).normalized * segSettings[i].len );
            }
        }

        public Vector2 Get(float globalT)
        {
            float unit = 1.0f / (1 + segSettings.Count);
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

        public Vector2 GetProjectTDis(Vector2 p)
        {
            //跟每个seg都算t（local）。选取t>0&&t<1的，并且PT最小的t。最后转化成globalT输出
            Vector2 p0, p1, p2;
            Vector2 temTDis, minTDis;
            minTDis = new Vector2(-1, 10000000);
            int inx = -1;
            for (int i = 0; i < GetSegNum(); i++)
            {
                GetSegPoints(i, out p0, out p1, out p2);
                temTDis = TDisToQuadraticBezier(p, p0, p1, p2);
                if(temTDis.y < minTDis.y && Is01(temTDis.x))
                {
                    inx = i;
                    minTDis = temTDis;
                }
            }
            float unit = 1.0f / GetSegNum();

            minTDis.x = unit * (inx + minTDis.x);
            return minTDis;
        }

        bool Is01(float x)
        {
            return x > 0 && x < 1;
        }

        float dd(Vector2 x)
        {
            return dot(x, x);
        }

        float addv(Vector2 a) { return a.x + a.y; }

        Vector2 solveCubic2(Vector3 a)
        {
            float p = a.y - a.x * a.x / 3.0f;
            float p3 = p * p * p;
            float q = a.x * (2.0f* a.x * a.x - 9.0f * a.y) / 27.0f+ a.z;
            float d = q * q + 4.0f* p3 / 27.0f;
            if (d > .0)
            {
                Vector2 x = (new Vector2(1, -1) * sqrt(d) - new Vector2(q,q)) * 0.5f;
                float tt = addv(sign(x) * pow(abs(x), ToVec2(1 / 3.0f))) - a.x / 3.0f;
                return ToVec2(tt);
            }
            float v = acos(-sqrt(-27.0f/ p3) * q * 0.5f) / 3.0f;
            float m = cos(v);
            float n = sin(v) * 1.732050808f;
            return new Vector2(m + m, -n - m) * sqrt(-p / 3.0f) - ToVec2(a.x / 3.0f);
        }
        //
        ////https://www.shadertoy.com/view/XdB3Ww
        //float calculateDistanceToQuadraticBezier(Vector2 p, Vector2 a, Vector2 b, Vector2 c)
        //{
        //    b += lerp(Vector2(1e-4, 1e-4), Vector2(0, 0), abs(sign(b * 2.0 - a - c)));
        //    Vector2 A = b - a;
        //    Vector2 B = c - b - A;
        //    Vector2 C = p - a;
        //    Vector2 D = A * 2.0f;
        //    Vector2 T = clamp(solveCubic2(Vector3(-3.* dot(A, B), dot(C, B) - 2.* dd(A), dot(C, A)) / -dd(B)), 0., 1.);
        //    return sqrt(min(dd(C - (D + B * T.x) * T.x), dd(C - (D + B * T.y) * T.y)));
        //}

        Vector2 TDisToQuadraticBezier(Vector2 p, Vector2 a, Vector2 b, Vector2 c)
        {
            b += lerp(ToVec2(1e-4f), ToVec2(0), abs(sign(b * 2.0f - a - c)));
            Vector2 A = b - a;
            Vector2 B = c - b - A;
            Vector2 C = p - a;
            Vector2 D = A * 2.0f;
            Vector2 T = (solveCubic2(new Vector3(-3.0f* dot(A, B), dot(C, B) - 2.0f* dd(A), dot(C, A)) / -dd(B)));

            float d1_square = dd(C - (D + B * T.x) * T.x);
            float d2_square = dd(C - (D + B * T.y) * T.y);

            return d1_square < d2_square ? new Vector2(T.x,sqrt(d1_square)) : new Vector2(T.y, sqrt(d2_square));
        }

        public Vector3 To3D(Vector2 p2d)
        {
            Vector3 p = new Vector3(p2d.x, 0, p2d.y);
            var worldRot = transform.rotation;
            p = (worldRot) * p;
            var worldPos = transform.position;
            p += worldPos;
            return p;
        }

        public List<Vector2> GetKeys()
        {
            List<Vector2> re = new List<Vector2>();
            for (int i = 0; i < GetSegNum(); i++)
            {
                if (i == 0)
                {
                    re.Add(pnt0);
                    re.Add(pnt1);
                    re.Add(pnt2);
                }
                else
                {
                    //p0 是上一个的p2，不用画
                    //画 p1, p2
                    //p1 from mids,p2 from settings
                    re.Add(mids[i - 1]);
                    re.Add(segSettings[i - 1].p2);
                }
            }
            return re;
        }
    }
}
