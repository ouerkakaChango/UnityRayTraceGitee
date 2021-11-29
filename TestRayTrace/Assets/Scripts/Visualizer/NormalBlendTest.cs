using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FastGeo;
using Vertex = FastGeo.Vertex;
using Plane = FastGeo.Plane;
using Ray = FastGeo.Ray;

public class NormalBlendTest : MonoBehaviour
{
    public enum TestType
    {
        triangle,
    };
    public TestType type = TestType.triangle;
    public Material mat;

    NormalVisualizer visual;

    Vector3[] vertices;
    Vector3[] normals;

    List<Vector3> samplePnts;
    List<Vector3> sampleNorms = new List<Vector3>();

    // Start is called before the first frame update
    void Start()
    {
        //1.
        if(type == TestType.triangle)
        {
            ConstructTestTriangle();
        }

        visual = gameObject.AddComponent<NormalVisualizer>();

        visual.mat = mat;
        visual.type = NormalVisualizer.VisualType.data;
        visual.AddData(vertices, normals);

        //2.从p1p2线段上均取n点，并沿着p2p3方向，与p1p3求交。设此线段为AB
        //将AB均分k点，每点计算blend
        SamplePointsInTri(vertices[0], vertices[1], vertices[2], out samplePnts);

        TestBlends();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void ConstructTestTriangle()
    {
        vertices = new Vector3[3];
        vertices[0] = new Vector3(-1, 0, -1);
        vertices[1] = new Vector3(1, 0, -1);
        vertices[2] = new Vector3(-1, 0, 1);

        normals = new Vector3[3];
        normals[0] = (new Vector3(-0.1f *20,1,-0.2f *20)).normalized;
        normals[1] = (new Vector3(0.1f *2, 1, -0.2f *2)).normalized;
        normals[2] = (new Vector3(-0.1f,1,0.2f)).normalized;
    }

    void SamplePointsInTri(Vector3 p1, Vector3 p2, Vector3 p3 , out List<Vector3> samplePnts)
    {
        samplePnts = new List<Vector3>();

        //从p1p2线段上均取n点，并沿着p2p3方向，与p1p3求交。设此线段为AB
        //将AB均分k点，每点计算blend
        float seg1 = 6;
        Vector3 step1 = (p2 - p1)/ seg1;
        Vector3 step2 = (p3 - p1) / seg1;
        List<Vector3> starts = new List<Vector3>();
        List<Vector3> ends = new List<Vector3>();
        for (int i=1;i<=seg1;i++)
        {
            starts.Add(p1 + step1 * i);
            ends.Add(p1 + step2 * i);
        }

        float seg2 = 6;
        for (int i=0;i<starts.Count;i++)
        {
            var start = starts[i];
            var end = ends[i];

            var step3 = (end - start) / seg2;
            for(int i1=0;i1<=seg2;i1++)
            {
                samplePnts.Add(start + i1 * step3);
            }
        }
    }

    void TestBlends()
    {
        var p1 = vertices[0];
        var p2 = vertices[1];
        var p3 = vertices[2];

        Vertex v1 = new Vertex();
        v1.p = vertices[0];
        v1.n = normals[0];

        Vertex v2 = new Vertex();
        v2.p = vertices[1];
        v2.n = normals[1];

        Vertex v3 = new Vertex();
        v3.p = vertices[2];
        v3.n = normals[2];

        foreach (var pnt in samplePnts)
        {
            sampleNorms.Add(RayMath.GetBlendedTriNorm(pnt, v1, v2, v3) );
        }

        var a1 = samplePnts.ToArray();
        var a2 = sampleNorms.ToArray();
        visual.AddData(in a1, in a2);
    }
}
