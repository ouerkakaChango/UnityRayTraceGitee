using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class ComputeShaderHelper 
{
    public static void PreComputeBufferOnce(ref ComputeBuffer buffer, int stride, in System.Array dataArr)
    {
        if (buffer != null)
        {
            return;
        }
        buffer = new ComputeBuffer(dataArr.Length, stride);
        buffer.SetData(dataArr);
    }

    public static void PreComputeBuffer(ref ComputeBuffer buffer, int stride, in System.Array dataArr)
    {
        buffer = new ComputeBuffer(dataArr.Length, stride);
        buffer.SetData(dataArr);
    }

    public static void SafeDispose(ComputeBuffer cb)
    {
        if (cb != null)
        {
            cb.Dispose();
        }
    }
}