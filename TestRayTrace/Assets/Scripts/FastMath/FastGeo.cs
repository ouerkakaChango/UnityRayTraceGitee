using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FastGeo
{

    public struct Ray
    {
        public Vector3 pos;
        public Vector3 dir;
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
    }
}