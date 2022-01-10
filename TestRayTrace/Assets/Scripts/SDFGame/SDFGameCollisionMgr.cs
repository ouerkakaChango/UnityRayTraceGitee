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

        Vector3 dMove = right * rightMove + forward * forwardMove;
        if (dMove.magnitude < 0.00001f)
        {
            return;
        }
        Vector3 dir = dMove.normalized;
        pos += r * dir;
        if (HitInScene(pos, pos + dMove))
        {
            rightMove = 0;
            forwardMove = 0;
        }
    }
}
