using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MathHelper;
using static MathHelper.Vec;
using static MathHelper.XMathFunc;
using Debugger;

namespace FastGeo
{

    public struct Ray
    {
        public Vector3 pos;
        public Vector3 dir;

        public Ray(in Vector3 pos_, in Vector3 dir_)
        {
            pos = pos_;
            dir = dir_;
        }
    }

    public struct Vertex
    {
        public Vector3 p;
        public Vector3 n;
    }

    public struct Plane
    {
        public Vector3 p;
        public Vector3 n;
    }

    public struct Line
    {
        public Vector3 a;
        public Vector3 b;

        public Line(Vector3 a_, Vector3 b_)
        {
            a = a_;
            b = b_;
        }

    }

    //#####################################################################
    public struct DisInfo
    {
        public float dis;
        public Vector3 p;
    }

    public struct HitInfo
    {
        public bool bHit;
        public Vector3 P;
        public Vector3 N;

        public static HitInfo Default()
        {
            HitInfo re;
            re.bHit = false;
            re.P = Vector3.zero;
            re.N = Vector3.zero;
            return re;
        }
    }

    public struct CastInfo
    {
        public bool bHit;
        public float dis;
        public static CastInfo Default()
        {
            CastInfo re;
            re.bHit = false;
            re.dis = 0;
            return re;
        }
    };
    //#####################################################################

    static public class Former
    {
        static public Plane FormPlane(Vector3 p1, Vector3 p2, Vector3 p3, Vector3 guideN)
        {
            Vector3 v1 = p2 - p1;
            Vector3 v2 = p3 - p1;
            Vector3 n = Vector3.Cross(v1, v2).normalized;
            if (Vector3.Dot(n, guideN) < 0)
            {
                n = -n;
            }
            Plane re;
            re.p = p1;
            re.n = n;
            return re;
        }

        static public Plane FormPlane(Vertex v1, Vertex v2, Vertex v3)
        {
            return FormPlane(v1.p, v2.p, v3.p, v1.n);
        }
    }

    public static class RayMath
    {
        //https://blog.csdn.net/qq_41524721/article/details/103490144
        static public float RayCastPlane(Ray ray, Plane plane)
        {
            return -Vector3.Dot(ray.pos - plane.p, plane.n) / Vector3.Dot(ray.dir, plane.n);
        }

        static public Vector3 Tri_P1CInterP2P3(Vector3 c, Vertex v1, Vertex v2, Vertex v3)
        {
            Vector3 p1 = v1.p;
            Vector3 p2 = v2.p;
            Vector3 p3 = v3.p;
            Plane plane1 = Former.FormPlane(v1, v2, v3);
            Vector3 n2 = Vector3.Cross(plane1.n, (p3 - p2).normalized);
            Plane plane2 = new Plane();
            plane2.n = n2;
            plane2.p = p2;
            Ray ray = new Ray();
            ray.pos = c;
            ray.dir = (c - p1).normalized;
            float k = RayCastPlane(ray, plane2);
            if (k < 0)
            {
                return c;
            }
            return c + k * ray.dir;
        }

        //1.1 获取p1c与p2p3的交点c2 https://blog.csdn.net/qq_41524721/article/details/121606678
        //1.2 根据相似，CA:C2P2 = P1C:P1C2 , 求出A
        static public void Tri_ParallelP2P3(out Vector3 A, out Vector3 B, Vector3 c, Vertex v1, Vertex v2, Vertex v3)
        {
            Vector3 p1 = v1.p;
            Vector3 p2 = v2.p;
            Vector3 p3 = v3.p;
            Vector3 c2 = Tri_P1CInterP2P3(c, v1, v2, v3);

            float lenCA = (p1 - c).magnitude * (p2 - c2).magnitude / (p1 - c2).magnitude;
            Vector3 dir1 = (p2 - p3).normalized;
            A = c + dir1 * lenCA;

            float lenCB = (p1 - c).magnitude * (p3 - c2).magnitude / (p1 - c2).magnitude;
            Vector3 dir2 = -dir1;
            B = c + dir2 * lenCB;
        }

        static public Vector3 GetBlendedTriNorm(Vector3 c, Vertex v1, Vertex v2, Vertex v3)
        {
            //根据A lerp(n1,n2)，根据B lerp(n1,n3)，根据c lerp(nA, nB)
            Vector3 p1 = v1.p;
            Vector3 p2 = v2.p;
            Vector3 p3 = v3.p;
            Vector3 A, B;
            Tri_ParallelP2P3(out A, out B, c, v1, v2, v3);

            float kA = (A - p1).magnitude / (p2 - p1).magnitude;
            Vector3 nA = Vector3.Lerp(v1.n, v2.n, kA);

            float kB = (B - p1).magnitude / (p3 - p1).magnitude;
            Vector3 nB = Vector3.Lerp(v1.n, v3.n, kB);

            float kC = (c - A).magnitude / (B - A).magnitude;
            return Vector3.Lerp(nA, nB, kC);
        }

        //默认该Normalize的已经normalize
        //Plane是quad所在plane,plane.p是quad的某顶点
        //size是quad的大小，v1,v2是以plane.p为起点，两边的方向向量，和size顺序对应
        public static CastInfo CastQuad_Corner(in Ray ray, in Plane plane, in Vector2 size, in Vector3 v1, in Vector3 v2)
        {
            CastInfo re = CastInfo.Default();

            if (dot(ray.dir, plane.n) >= 0)
            {
                return re;
            }

            re.dis = RayCastPlane(ray, plane);
            if (re.dis < 0)
            {
                return re;
            }
            Vector3 hitP = ray.pos + re.dis * ray.dir;
            Vector3 center = plane.p + v1 * size.x / 2 + v2 * size.y / 2;
            Vector3 dv = hitP - center;
            re.bHit = (abs(dot(dv, v1)) <= (size.x / 2)) &&
                (abs(dot(dv, v2)) <= (size.y / 2));
            return re;
        }

        public static bool IsInBBox(in Vector3 p, in Vector3 min, in Vector3 max)
        {
            return gt(p, min) && lt(p, max);
        }

        //1.从x,y,z方向，每两个平面和ray测交点
        //只要有一个交点在bbox内，则返回true
        public static CastInfo CastBBox(in Ray ray, in Vector3 min, in Vector3 max)
        {
            CastInfo re = CastInfo.Default();

            if (gt(ray.pos, min) && lt(ray.pos, max))
            {
                re.bHit = true;
                return re;
            }

            //1.x方向
            Plane plane;
            plane.p = min;
            plane.n = new Vector3(-1, 0, 0);
            Vector2 quadSize = new Vector2(max.y - min.y, max.z - min.z);//max.yz - min.yz;
            re = CastQuad_Corner(ray, plane, quadSize, new Vector3(0, 1, 0), new Vector3(0, 0, 1));
            if (re.bHit)
            {
                return re;
            }

            plane.p = max;
            plane.n = new Vector3(1, 0, 0);
            re = CastQuad_Corner(ray, plane, quadSize, new Vector3(0, -1, 0), new Vector3(0, 0, -1));
            if (re.bHit)
            {
                return re;
            }

            //2.y方向
            plane.p = min;
            plane.n = new Vector3(0, -1, 0);
            quadSize = new Vector2(max.x - min.x, max.z - min.z);//max.xz - min.xz;
            re = CastQuad_Corner(ray, plane, quadSize, new Vector3(1, 0, 0), new Vector3(0, 0, 1));
            if (re.bHit)
            {
                return re;
            }

            plane.p = max;
            plane.n = new Vector3(0, 1, 0);
            re = CastQuad_Corner(ray, plane, quadSize, new Vector3(-1, 0, 0), new Vector3(0, 0, -1));
            if (re.bHit)
            {
                return re;
            }

            //3.z方向
            plane.p = min;
            plane.n = new Vector3(0, 0, -1);
            quadSize = new Vector2(max.x - min.x, max.y - min.y);//max.xy - min.xy;
            re = CastQuad_Corner(ray, plane, quadSize, new Vector3(1, 0, 0), new Vector3(0, 1, 0));
            if (re.bHit)
            {
                return re;
            }

            plane.p = max;
            plane.n = new Vector3(0, 0, 1);
            re = CastQuad_Corner(ray, plane, quadSize, new Vector3(-1, 0, 0), new Vector3(0, -1, 0));
            if (re.bHit)
            {
                return re;
            }

            return re;
        }

        static bool FrontFace(Vector3 pos, Plane plane)
        {
            return Vector3.Dot(pos - plane.p, plane.n) >= 0;
        }

        //所谓"重心法"：https://blog.csdn.net/wkl115211/article/details/80215421
        public static bool IsPointInsideTri(Vector3 pos, Vector3 p1, Vector3 p2, Vector3 p3)
        {
            Vector3 v0 = p3 - p1;
            Vector3 v1 = p2 - p1;
            Vector3 v2 = pos - p1;

            float dot00 = dot(v0, v0);
            float dot01 = dot(v0, v1);
            float dot02 = dot(v0, v2);
            float dot11 = dot(v1, v1);
            float dot12 = dot(v1, v2);

            float invDeno = 1 / (dot00 * dot11 - dot01 * dot01);

            float u = (dot11 * dot02 - dot01 * dot12) * invDeno;
            if (u < 0 || u > 1)
            {
                return false;
            }

            float v = (dot00 * dot12 - dot01 * dot02) * invDeno;
            if (v < 0 || v > 1)
            {
                return false;
            }

            return u + v <= 1;
        }

        //根据A lerp(n1,n2)，根据B lerp(n1,n3)，根据c lerp(nA, nB)
        public static Vector3 GetTriBlendedNorm(Vector3 c, Vertex v1, Vertex v2, Vertex v3)
        {
            Vector3 p1 = v1.p;
            Vector3 p2 = v2.p;
            Vector3 p3 = v3.p;

            float lenP2P1 = length(p2 - p1);
            float lenP3P1 = length(p3 - p1);

            if (NearZero(lenP2P1))
            {
                return lerp(v1.n, v3.n, 0.5f);
            }
            if (NearZero(lenP3P1))
            {
                return lerp(v1.n, v2.n, 0.5f);
            }

            Vector3 A, B;
            Tri_ParallelP2P3(out A, out B, c, v1, v2, v3);

            float kA = length(A - p1) / lenP2P1;
            Vector3 nA = lerp(v1.n, v2.n, kA);

            float kB = length(B - p1) / lenP3P1;
            Vector3 nB = lerp(v1.n, v3.n, kB);

            float lenAB = length(B - A);
            float kC = 0;
            if (NearZero(lenAB))
            {
                kC = 0.5f;
            }
            else
            {
                kC = length(c - A) / lenAB;
            }
            return lerp(nA, nB, kC);
        }

        //(三个vert的法线不一定一致)
        //1.先3p组成平面,其plane.N要和v1.n的Vector3.Dot为正
        //2.得到与平面交点，判断是否在三角形内（重心法）
        //3.根据位置Blend三个vert的N
        public static HitInfo RayCastTri(Ray ray, Vertex v1, Vertex v2, Vertex v3)
        {
            HitInfo re = HitInfo.Default();

            Plane plane = Former.FormPlane(v1.p, v2.p, v3.p, v1.n);

            if (!FrontFace(ray.pos, plane))
            {
                return re;
            }

            float k = RayCastPlane(ray, plane);

            //如果屏幕在射线反方向
            if (k < 0)
            {
                return re;
            }

            re.P = ray.pos + ray.dir * k;
            re.bHit = IsPointInsideTri(re.P, v1.p, v2.p, v3.p);

            //如果打点在三角形之外
            if (!re.bHit)
            {
                return re;
            }

            //Blend三个顶点的Normal
            re.N = GetTriBlendedNorm(re.P, v1, v2, v3);

            return re;
        }
    }

    public static class LineMath
    {
        public static DisInfo LineDis(Line line, Vector3 p)
        {
            DisInfo re;
            Vector3 ap = p - line.a;
            float d2 = ap.sqrMagnitude;
            Vector3 dir = (line.b - line.a).normalized;
            float proj = Vector3.Dot(ap, dir);
            re.dis = Mathf.Sqrt(d2 - proj * proj);
            re.p = line.a + dir * proj;
            return re;
        }

        public static bool LineIntersect_Sphere(Line line, Vector3 center, float r)
        {
            //1.直线距离球心最短距都大于r，不相交
            DisInfo disInfo = LineDis(line, center);
            if (disInfo.dis > r)
            {
                return false;
            }

            //2.两点任意一点在球内，intersect
            if ((line.a - center).magnitude <= r ||
                (line.b - center).magnitude <= r)
            {
                return true;
            }

            //3.两点在垂足两端（前面已经判断不在球内），且直线距离已经小于r，那必然相交；否则必然不交
            Vector3 pa = line.a - disInfo.p;
            Vector3 pb = line.b - disInfo.p;
            return Vector3.Dot(pa, pb) < 0;
        }

        public static bool LineIntersect_BBox(Line line, Vector3 center, Vector3 bound)
        {
            Vector3 min = center - bound;
            Vector3 max = min + 2.0f*bound;
            if (RayMath.IsInBBox(line.a, min, max) || RayMath.IsInBBox(line.b, min, max))
            {
                //Debug.Log("1");
                return true;
            }

            if (NearZero(line.b - line.a))
            {
                //Debug.Log("2");
                return false;
            }

            Ray ray = new Ray();
            ray.pos = line.a;
            ray.dir = normalize(line.b - line.a);

            CastInfo info = RayMath.CastBBox(ray, min, max);

            if (info.bHit)
            {
                //Debug.Log("3.1");
                return info.dis <= length(line.b - line.a);
            }
            else
            {
                //Debug.Log("3.2");
                return false;
            }
        }
    }

    public static class GridMath
    {
        static int ModInx(float x, float cellLength)
        {
            if (x < 0 || cellLength <= 0)
            {
                return -1;
            }
            return (int)((x - fmod(x, cellLength)) / cellLength);
        }

        static Vector3 ModInx(Vector3 p, Vector3 cellLength)
        {
            return new Vector3(ModInx(p.x, cellLength.x),
                ModInx(p.y, cellLength.y),
                ModInx(p.z, cellLength.z));
        }

        public static Vector3Int GetCellInx(in Vector3 pntPos, in Vector3 startPos, in Vector3 unit, in Vector3 subDivide)
        {
            Vector3 local = pntPos - startPos;
            Vector3Int inx = Vec.ToInt(ModInx(local, unit));

            //在计算pntPos的cellInx的时候，计算的是cell内的左下方点，
            //但是当p正好在右上方的时候，用Mod已经越过了这个cell，正好在(+1,+1,+1)的左下方点，需要-1处理
            if (equal(inx.x, subDivide.x))
            {
                inx.x -= 1;
            }
            if (equal(inx.y, subDivide.y))
            {
                inx.y -= 1;
            }
            if (equal(inx.z, subDivide.z))
            {
                inx.z -= 1;
            }
            return inx;
        }
    }
}