using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static StringTool.StringHelper;

public class AutoCS : MonoBehaviour
{
    public List<string> templates;
    public List<string> outs;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Generate()
    {
        //将templates,outs等写入config
        //调用外部控制台程序exe，进行config+templates => outs

        //Debug.Log(ChopEnd("SDFGameCS/CS_SDFGame.compute",".compute"));
    }
}
