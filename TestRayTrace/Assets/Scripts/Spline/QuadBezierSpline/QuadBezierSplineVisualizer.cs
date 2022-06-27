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
    public Vector2 testP;
    [ReadOnly]
    public List<Vector2> keys = new List<Vector2>();
    [ReadOnly]
    public List<Vector3> keys3D = new List<Vector3>();

    [ReadOnly]
    public bool bInited = false;

    public bool showTest = false;

    bool bShow3D = true;
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
        DoVisualize();
        
    }

    //########################################################

    void DoVisualize()
    {
        if (bInited)
        {
            Gizmos.color = Color.red;
            //Debug.Log(spline.GetSegNum());
            for (int i = 0; i < spline.GetSegNum(); i++)
            {
                if (i == 0)
                {
                    Gizmos.DrawCube(To3D(spline.pnt0), 0.1f * scale * Vector3.one);
                    Gizmos.DrawCube(To3D(spline.pnt1), 0.1f * scale * Vector3.one);
                    Gizmos.DrawCube(To3D(spline.pnt2), 0.1f * scale * Vector3.one);

                    UnityEditor.Handles.Label(To3D(spline.pnt0), "p0");
                    UnityEditor.Handles.Label(To3D(spline.pnt1), "p1");
                    UnityEditor.Handles.Label(To3D(spline.pnt2), "p2");
                }
                else
                {
                    //p0 是上一个的p2，不用画
                    //画 p1, p2
                    //p1 from mids,p2 from settings
                    Gizmos.DrawCube(To3D(spline.mids[i - 1]), 0.1f * scale * Vector3.one);
                    Gizmos.DrawCube(To3D(spline.segSettings[i - 1].p2), 0.1f * scale * Vector3.one);

                    UnityEditor.Handles.Label(To3D(spline.mids[i - 1]), "p" + (2 * i + 1));
                    UnityEditor.Handles.Label(To3D(spline.segSettings[i - 1].p2), "p" + (2 * i + 2));
                }
            }
            Gizmos.color = Color.black;
            float divideUnit = 1.0f / divide;
            for (int i = 1; i < divide; i++)
            {
                float t = i * divideUnit;
                Vector2 p = spline.Get(t);
                Gizmos.DrawCube(To3D(p), 0.05f * scale * Vector3.one);
            }

            if (showTest)
            {
                Gizmos.color = Color.blue;
                Gizmos.DrawCube(To3D(testP), 0.1f * scale * Vector3.one);
                Vector2 testTDis = spline.GetProjectTDis(testP);
                if (testTDis.x > 0)
                {
                    Gizmos.color = new Color(0.1f, 0.1f, 1);
                    Vector3 testPos = To3D(testP);
                    Vector2 testPro = spline.Get(testTDis.x);
                    Vector3 testProPos = To3D(testPro);
                    Gizmos.DrawCube(testProPos, 0.1f * scale * Vector3.one);
                    Vector3 dir = (testProPos - testPos).normalized;
                    Gizmos.DrawLine(testPos, testPos + dir * testTDis.y);
                }
            }
        }
    }

    Vector3 To3D(in Vector2 p)
    {
        if (!bShow3D)
        {
            return new Vector3(p.x, transform.position.y, p.y);
        }
        else
        {
            return ToSpline3D(p);
        }
    }

    public void Init()
    {
        spline.Init();
        bInited = true;
    }

    public void ShowKeys()
    {
        bShow3D = false;
        if (!bInited)
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

    public void ShowKeys3D()
    {
        ShowKeys();
        bShow3D = true;
    }

    public Vector3 ToSpline3D(Vector2 v)
    {
        return spline.To3D(v);
    }
}
