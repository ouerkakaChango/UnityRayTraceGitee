using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Debugger;

//start,end是tri，左闭右开
struct BVHNode
{
    public int start;
    public int end;
    public Vector3 min;
    public Vector3 max;
}

struct Line
{
    public Vector3 p1;
    public Vector3 p2;
}

//参考：https://blog.csdn.net/weixin_39548859/article/details/107490251
//使用最简单的思路
//1.对于每个bbox，找3轴最长k轴切2分
//2.切2分的标准为，沿k轴，数量为一半的三角形 （根据三角形重心，按k轴排序）
public class BVHTool : MonoBehaviour
{
    static public float MAXFloat = 100000.0f;

    public Material mat;

    Mesh mesh;
    Vector3[] vertices;
    int[] tris;
    BVHNode root;

    List<Line> lines = new List<Line>();

    // Start is called before the first frame update
    void Start()
    {
        var meshFiliter = gameObject.GetComponent<MeshFilter>();
        mesh = meshFiliter.mesh;

        Init();

        BuildBVH();
    }

    // Update is called once per frame
    void Update()
    {
       
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
    }

    void OnRenderObject()
    {
        RenderBBox();
    }

    void Init()
    {
        vertices = mesh.vertices;
        ToWorldCoord();
        tris = mesh.triangles;
        SetNode(ref root,0,tris.Length/3);

        AddRender(root);
        //Log.DebugVec(root.min);
        //Log.DebugVec(root.max);
    }

    void ToWorldCoord()
    {
        var local2world = gameObject.transform.localToWorldMatrix;
        Debug.Log("Trans ing...");
        for (int i = 0; i < vertices.Length; i++)
        {
            vertices[i] = local2world.MultiplyPoint3x4(vertices[i]);
        }
        Debug.Log("Trans done.");
    }

    void SetNode(ref BVHNode root, int start, int end)
    {
        root.start = start;
        root.end = end;

        //遍历，设置bbox的minmax X,Y,Z (2个float3)
        Vector3 min = Vector3.one * MAXFloat;
        Vector3 max = -Vector3.one * MAXFloat;

        for (int i = start; i < end; i++)
        {
            var p1 = vertices[tris[3 * i]];
            var p2 = vertices[tris[3 * i + 1]];
            var p3 = vertices[tris[3 * i + 2]];

            CheckMinMax(p1, ref min, ref max);
            CheckMinMax(p2, ref min, ref max);
            CheckMinMax(p3, ref min, ref max);
        }
        root.min = min;
        root.max = max;
    }

    void CheckMinMax(in Vector3 p, ref Vector3 min, ref Vector3 max)
    {
        if (p.x < min.x)
        {
            min.x = p.x;
        }
        if (p.y < min.y)
        {
            min.y = p.y;
        }
        if (p.z < min.z)
        {
            min.z = p.z;
        }

        if (p.x > max.x)
        {
            max.x = p.x;
        }
        if (p.y > max.y)
        {
            max.y = p.y;
        }
        if (p.z > max.z)
        {
            max.z = p.z;
        }
    }

    Line MakeLine(in Vector3 p1, in Vector3 p2)
    {
        Line re = new Line();
        re.p1 = p1;
        re.p2 = p2;
        return re;
    }

    void AddRender(in BVHNode node)
    {
        // 4 5 6 7
        // 0 1 2 3
        var p = GetBBoxVerts(node.min, node.max);
        lines.Add(MakeLine(p[0], p[1]));
        lines.Add(MakeLine(p[1], p[2]));
        lines.Add(MakeLine(p[2], p[3]));
        lines.Add(MakeLine(p[3], p[0]));

        lines.Add(MakeLine(p[0], p[4]));
        lines.Add(MakeLine(p[1], p[5]));
        lines.Add(MakeLine(p[2], p[6]));
        lines.Add(MakeLine(p[3], p[7]));

        lines.Add(MakeLine(p[0+4], p[1+4]));
        lines.Add(MakeLine(p[1+4], p[2+4]));
        lines.Add(MakeLine(p[2+4], p[3+4]));
        lines.Add(MakeLine(p[3+4], p[0+4]));
    }

    void RenderBBox()
    {
        mat.SetPass(0);
        GL.Color(new Color(1, 1, 0, 0.8f));
        GL.PushMatrix();
        GL.Begin(GL.LINES);

        for (int i = 0; i < lines.Count; i++)
        {
            GL.Vertex(lines[i].p1);
            GL.Vertex(lines[i].p2);
        }

        GL.End();
        GL.PopMatrix();
    }

    Vector3[] GetBBoxVerts(in Vector3 min, in Vector3 max)
    {
        Vector3[] re = new Vector3[8];
        re[0] = new Vector3(min.x, min.y, min.z);
        re[1] = new Vector3(max.x, min.y, min.z);
        re[2] = new Vector3(max.x, max.y, min.z);
        re[3] = new Vector3(min.x, max.y, min.z);
        re[4] = new Vector3(min.x, min.y, max.z);
        re[5] = new Vector3(max.x, min.y, max.z);
        re[6] = new Vector3(max.x, max.y, max.z);
        re[7] = new Vector3(min.x, max.y, max.z);
        return re;
    }

    void BuildBVH()
    {
        
    }
}
