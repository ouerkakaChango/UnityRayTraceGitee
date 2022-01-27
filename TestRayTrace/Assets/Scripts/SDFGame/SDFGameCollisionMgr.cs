using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SDFUtility;
using static SDFUtility.SDFMath;
using FastGeo;
using static FastGeo.LineMath;
using static MathHelper.XMathFunc;
using Debugger;

public class SDFGameCollisionMgr : MonoBehaviour
{
     int OBJNUM = 2;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //bool IntersectSceneSDF(Line line)
    //{
    //    //???
    //    return LineIntersect_Sphere(line, new Vector3(0, 0.5f, 0), 0.5f) ||
    //        LineIntersect_BBox(line, new Vector3(0, -0.5f, 0), new Vector3(5, 0.5f, 5));
    //}
    //
    //public bool HitInScene(Vector3 start, Vector3 end)
    //{
    //    Line line = new Line(start, end);
    //    return IntersectSceneSDF(line);
    //}

    bool IntersectSceneObjectSDF(int inx, Line line, float r)
    {
        if (inx == 0)
        {
            return LineIntersect_Sphere(line, new Vector3(0, 0.5f, 0), 0.5f+r);
        }
        else if (inx == 1)
        {
            return LineIntersect_BBox(line, new Vector3(0, -0.5f, 0), new Vector3(5, 0.5f, 5)+r*Vector3.one);
        }
        else
        {
            Debug.LogError("error in IntersectSceneObjectSDF");
            return false;
        }
    }
    //##############################################
    float GetSceneObjSDF(int inx, Vector3 p)
    {
        if (inx == 0)
        {
            return SDFSphere(p, new Vector3(0, 0.5f, 0), 0.5f);
        }
        else if (inx == 1)
        {
            return SDFBox(p, new Vector3(0, -0.5f, 0), new Vector3(5, 0.5f, 5));
        }
        else
        {
            Debug.LogError("error in GetSceneObjSDF");
            return 1000;
        }
    }

    Vector3 GetSceneObjSDFNormal(int inx, Vector3 p)
    {
        float epsilon = 0.00001f;
        return normalize(new Vector3(
            GetSceneObjSDF(inx, new Vector3(p.x + epsilon, p.y, p.z)) - GetSceneObjSDF(inx, new Vector3(p.x - epsilon, p.y, p.z)),
            GetSceneObjSDF(inx, new Vector3(p.x, p.y + epsilon, p.z)) - GetSceneObjSDF(inx, new Vector3(p.x, p.y - epsilon, p.z)),
            GetSceneObjSDF(inx, new Vector3(p.x, p.y, p.z + epsilon)) - GetSceneObjSDF(inx, new Vector3(p.x, p.y, p.z - epsilon))
            ));
    }

    Vector3 SceneObjNormal(int inx, Vector3 p)
    {
        if (inx == 0)
        {
            return SDFSphereNormal(p, new Vector3(0, 0.5f, 0));
        }
        else if (inx == 1)
        {
            return GetSceneObjSDFNormal(inx, p);
        }
        else
        {
            Debug.LogError("error in SceneObjNormal");
            return Vector3.zero;
        }
    }

    //用闵可夫斯基和，将圆柱求交，转化成线段求交
    public void CheckSphereMovement(SDFSphere shape, Vector3 pos, Vector3 right, Vector3 forward, ref float rightMove, ref float forwardMove)
    {
        float r = shape.GetRadiusInDir(right);

        Vector3 dMove = right * rightMove + forward * forwardMove;
        if (dMove.magnitude < 0.00001f)
        {
            return;
        }
        bool bHit = false;

        for (int i = 0; i < OBJNUM; i++)
        {
            if (IntersectSceneObjectSDF(i,new Line(pos, pos+dMove),r))
            {
                bHit = true;
                break;
            }
        }

        if (bHit)
        {
            rightMove = 0;
            forwardMove = 0;
        }
    }

    public void CheckMovement(SDFShape shape, Vector3 pos , Vector3 right, Vector3 forward, ref float rightMove, ref float forwardMove)
    {
        if (shape == null)
        {
            Debug.LogError("shape is null");
            return;
        }

        //Debug.Log(shape.GetType());
        if (shape.GetType() == typeof(SDFSphere))
        {
            CheckSphereMovement((SDFSphere)shape, pos, right, forward, ref rightMove, ref forwardMove);
        }

        
    }
}
