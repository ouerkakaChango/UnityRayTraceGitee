using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XFileHelper;

public enum MeshSDFExtendType
{
    None,
    Ground,
    All,
};

public class MeshSDF : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public static void ParseGPU(TextAsset file, out MeshSDFGrid grid, out MeshSDFGPUArrData[] sdfArr)
    {
        grid = new MeshSDFGrid();
        var reader = FileHelper.BeginRead(file);
        reader.Read(ref grid.startPos);
        reader.Read(ref grid.unitCount);
        reader.Read(ref grid.unit);

        int len = reader.ReadInt32();
        sdfArr = new MeshSDFGPUArrData[len];
        for (int i = 0; i < len; i++)
        {
            sdfArr[i].sdf = reader.ReadSingle();
        }
        reader.Close();

        reader.Close();
    }
}
