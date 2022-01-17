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

    public List<Line> missLines = new List<Line>();
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
            Gizmos.DrawLine(hitLines[i].a , hitLines[i].b );
        }
        for (int i = 0; i < hitPnts.Count; i++)
        {
            Gizmos.DrawCube(hitPnts[i] , Vector3.one * 0.02f);
        }

        Gizmos.color = Color.magenta;

        //missLines
        for (int i = 0; i < missLines.Count; i++)
        {
            Gizmos.DrawLine(missLines[i].a, missLines[i].b);
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
            hitLines.Add(new Line(ray.pos, hitInfo.P));
            hitPnts.Add(hitInfo.P);
        }
        else
        {
            missLines.Add(new Line(ray.pos, ray.pos + 20 * ray.dir));
        }
    }

    public void ClearAll()
    {
        ClearAllLines();
        hitPnts.Clear();
    }

    public void ClearAllLines()
    {
        hitLines.Clear();
        missLines.Clear();
    }
}
