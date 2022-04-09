using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XUtility;

using Spline;

public class QuadBezierSplineVisualizer : MonoBehaviour
{
    QuadBezierSpline spline;

    public float scale = 1.0f;
    public int divide = 10;
    [ReadOnly]
    public List<Vector2> keys = new List<Vector2>();

    [ReadOnly]
    public bool bInited = false;
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
        if (!spline)
        {
            spline = GetComponent<QuadBezierSpline>();
        }

        if(bInited)
        {
            Gizmos.color = Color.red;
            for (int i=0;i<spline.GetSegNum();i++)
            {
                if(i==0)
                {
                    Gizmos.DrawCube(To3D(spline.pnt0), 0.1f * scale * Vector3.one);
                    Gizmos.DrawCube(To3D(spline.pnt1), 0.1f * scale * Vector3.one);
                    Gizmos.DrawCube(To3D(spline.pnt2), 0.1f * scale * Vector3.one);
                }
                else
                {
                    //p0 是上一个的p2，不用画
                    //画 p1, p2
                    //p1 from mids,p2 from settings
                    Gizmos.DrawCube(To3D(spline.mids[i-1]), 0.1f * scale * Vector3.one);
                    Gizmos.DrawCube(To3D(spline.segSettings[i - 1].p2), 0.1f * scale * Vector3.one);
                }
            }
            Gizmos.color = Color.black;
            float divideUnit = 1.0f / divide;
            for(int i=1;i<divide;i++)
            {
                float t = i * divideUnit;
                Vector2 p = spline.Get(t);
                Gizmos.DrawCube(To3D(p), 0.05f * scale * Vector3.one);
            }
        }
    }

    //########################################################
    Vector3 To3D(in Vector2 p)
    {
        return new Vector3(p.x, transform.position.y, p.y);
    }

    public void Init()
    {
        spline.Init();
        bInited = true;
    }

    public void ShowKeys()
    {
        if(!bInited)
        {
            Init();
        }
        keys.Clear();
        keys.Add(spline.pnt0);
        keys.Add(spline.pnt1);
        keys.Add(spline.pnt2);
        for(int i=0;i<spline.mids.Count;i++)
        {
            keys.Add(spline.mids[i]);
            keys.Add(spline.segSettings[i].p2);
        }
    }
}
