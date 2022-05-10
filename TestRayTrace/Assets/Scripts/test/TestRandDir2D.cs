using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MathHelper.CPURand;

[ExecuteInEditMode]
public class TestRandDir2D : MonoBehaviour
{
    public bool hasUpdated = false;
    public int num = 100;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(!hasUpdated)
        {
            Do();
            hasUpdated = true;
        }
    }

    //###########################################
    void Do()
    {
        var visual = GetComponent<PntsVisualizer>();
        if(visual)
        {
            //x-z
            for(int i=0;i< num; i++)
            {
                var dir = RandDir2D();
                visual.Add(new Vector3(dir.x, transform.position.y, dir.y));
            }
        }
    }

}
