using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MathHelper;

public class RandVisualizer : MonoBehaviour
{
    Vector3[] pnts;
    public MeshSDFGenerator meshSDFGenerator;
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
        if (pnts != null)
        {
            Gizmos.color = Color.blue;
            for (int i = 0; i < pnts.Length; i++)
            {
                Gizmos.DrawSphere(transform.position + pnts[i], 0.01f);
            }
        }
    }

    public void RandSphere()
    {
        pnts = new Vector3[1000];
        //for (int i = 0; i < pnts.Length; i++)
        //{
        //    //pnts[i] = CPURand.random_on_unit_sphere();
        //    pnts[i] = meshSDFGenerator.GetSampleDir(transform.position, i, new Vector3(0,0,0));
        //}
        for (int k = 0; k < 10; k++)
        {
            for (int j = 0; j < 10; j++)
            {
                for (int i = 0; i < 10; i++)
                {
                    int inx = i + j * 10 + k * 10 * 10;
                    pnts[i+j*10+k*10*10] = meshSDFGenerator.GetSampleDir(transform.position, inx, new Vector3(i, j, k));
                }
            }
        }
    }
}