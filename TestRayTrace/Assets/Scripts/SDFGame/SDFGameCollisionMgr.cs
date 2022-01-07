using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SDFUtility;
using static SDFUtility.SDFMath;
using FastGeo;
using static FastGeo.LineMath;

public class SDFGameCollisionMgr : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    float SceneSDF(Vector3 p)
    {
        //??? 
        return SDFSphere(p, new Vector3(0, 0.5f, 0), 0.5f);
    }

    public bool HitInScene(Vector3 p)
    {
        return SceneSDF(p) <= 0;
    }

    bool IntersectSceneSDF(Line line)
    {
        //???
        return LineIntersect_Sphere(line, new Vector3(0, 0.5f, 0), 0.5f);
    }

    public bool HitInScene(Vector3 start, Vector3 end)
    {
        Line line = new Line(start, end);
        return IntersectSceneSDF(line);
    }

    public void CheckMovement(SDFShape shape, Vector3 pos , Vector3 right, Vector3 forward, ref float rightMove, ref float forwardMove)
    {
        if (shape == null)
        {
            Debug.LogError("shape is null");
            return;
        }

        float r = shape.GetRadiusInDir(right);
        //if (HitInScene(pos + (r + rightMove) * right)) 
        //速度太快会穿墙，不能只根据结束点判断
        if(HitInScene(pos + r * right, pos + (r + rightMove) * right))
        {
            rightMove = 0;
        }

        r = shape.GetRadiusInDir(forward);
        //if (HitInScene(pos+ (r + forwardMove) * forward))
        if (HitInScene(pos + r * forward, pos + (r + forwardMove) * forward))
        {
            forwardMove = 0;
        }
    }
}
