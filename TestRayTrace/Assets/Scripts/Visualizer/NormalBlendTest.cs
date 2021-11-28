using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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
    // Start is called before the first frame update
    void Start()
    {
        if(type == TestType.triangle)
        {
            ConstructTestTriangle();
        }

        visual = gameObject.AddComponent<NormalVisualizer>();

        visual.mat = mat;
        visual.type = NormalVisualizer.VisualType.data;
        visual.AddData(vertices, normals);
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
}
