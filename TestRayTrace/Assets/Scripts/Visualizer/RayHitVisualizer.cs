using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FastGeo;
using Ray = FastGeo.Ray;

//[ExecuteInEditMode]
public class RayHitVisualizer : MonoBehaviour
{
    public List<Line> hitLines = new List<Line>();
    public List<Vector3> hitPnts = new List<Vector3>();
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;

        for (int i = 0; i < hitLines.Count; i++)
        {
            Gizmos.DrawLine(hitLines[i].a, hitLines[i].b);
        }
        for (int i = 0; i < hitPnts.Count; i++)
        {
            Gizmos.DrawCube(hitPnts[i], Vector3.one * 0.02f);
        }
    }

    void OnRenderObject()
    {
    }

    //###################################################
    public void Add(in Ray ray, in HitInfo hitInfo)
    {
        if (hitInfo.bHit)
        {
            hitLines.Add(new Line(ray.pos, hitInfo.p));
            hitPnts.Add(hitInfo.p);
        }
    }
}
