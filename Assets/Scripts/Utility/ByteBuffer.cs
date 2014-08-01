using UnityEngine;
using System.Collections;
using System.IO;
using System.Text;
using System;

public class ByteBuffer {
    MemoryStream stream = null;
    BinaryWriter writer = null;
    BinaryReader reader = null;

    private ByteBuffer(byte[] data) {
        if (data != null) {
            stream = new MemoryStream(data);
            reader = new BinaryReader(stream);
        } else {
            stream = new MemoryStream();
            writer = new BinaryWriter(stream);
        }
    }

    public static ByteBuffer Create(byte[] data) {
        return new ByteBuffer(data);
    }

    public static ByteBuffer Create() {
        return new ByteBuffer(null);
    }

    public void Close() {
        if (writer != null) writer.Close();
        if (reader != null) reader.Close();

        stream.Close();
        writer = null;
        reader = null;
        stream = null;
    }

    public void WriteByte (int v) {
        writer.Write((byte)v);
    }

    public void WriteInt(int v) {
        writer.Write(Converter.GetBigEndian((int)v));
    }

    public void WriteShort(ushort v) {
        writer.Write(Converter.GetBigEndian((ushort)v));
    }

    public void WriteLong(long v) {
        writer.Write(Converter.GetBigEndian((long)v));
    }

    public void WriteFloat(float v) {
        byte[] temp = BitConverter.GetBytes(v);
        Array.Reverse(temp);
        writer.Write(BitConverter.ToSingle(temp, 0));
    }

    public void WriteDouble(double v) {
        byte[] temp = BitConverter.GetBytes(v);
        Array.Reverse(temp);
        writer.Write(BitConverter.ToDouble(temp, 0));
    }

    public void WriteString(string v) {
        writer.Write(Converter.GetBigEndian((ushort)v.Length));
        byte[] bytes = Encoding.UTF8.GetBytes(v);
        writer.Write(bytes);
    }

    public int ReadByte () {
        return (int)reader.ReadByte(); 
    }

    public int ReadInt() {
        return Converter.GetBigEndian((int)reader.ReadInt32());
    }

    public ushort ReadShort() {
        return Converter.GetBigEndian((ushort)reader.ReadInt16());
    }

    public long ReadLong() {
        return Converter.GetBigEndian((long)reader.ReadInt64());
    }

    public float ReadFloat() {
        byte[] temp = BitConverter.GetBytes(reader.ReadSingle());
        Array.Reverse(temp);
        return BitConverter.ToSingle(temp, 0);
    }

    public double ReadDouble() {
        byte[] temp = BitConverter.GetBytes(reader.ReadDouble());
        Array.Reverse(temp);
        return BitConverter.ToDouble(temp, 0);
    }

    public string ReadString() {
        ushort len = ReadShort();
        byte[] buffer = new byte[len];
        buffer = reader.ReadBytes(len);
        return Encoding.UTF8.GetString(buffer);
    }

    public byte[] ToBytes() {
        writer.Flush();
        return stream.ToArray();
    }

    public void Flush() {
        writer.Flush();
    }
}
