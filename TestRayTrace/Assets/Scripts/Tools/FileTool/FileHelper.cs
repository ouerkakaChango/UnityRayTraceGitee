using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace XFileHelper
{
    public static class FileHelper
    {
        public static BinaryWriter BeginWrite(string path)
        {
            FileStream savedFile = new FileStream(path, FileMode.CreateNew, FileAccess.Write);
            var writer = new BinaryWriter(savedFile);
            return writer;
        }

        public static void Write(this BinaryWriter writer, in int[] arr)
        {
            writer.Write(arr.Length);
            for (int i = 0; i < arr.Length; i++)
            {
                writer.Write(arr[i]);
            }
        }

        public static void Write(this BinaryWriter writer, in Vector3 v)
        {
            writer.Write(v.x);
            writer.Write(v.y);
            writer.Write(v.z);
        }

        //################################
        public static BinaryReader BeginRead(string path)
        {
            FileStream savedFile = new FileStream(path, FileMode.Open, FileAccess.Read);
            var reader = new BinaryReader(savedFile);
            return reader;
        }

        public static void Read(this BinaryReader reader, ref int[] arr)
        {
            int len = reader.ReadInt32();
            if (len <= 0)
            {
                return;
            }
            arr = new int[len];
            for (int i = 0; i < len; i++)
            {
                arr[i] = reader.ReadInt32();
            }
        }

        public static void Read(this BinaryReader reader, ref Vector3 v)
        {
            v.x = reader.ReadSingle();
            v.y = reader.ReadSingle();
            v.z = reader.ReadSingle();
        }
    };
}