using UnityEngine;
using System.Collections;

public class GaussianBlur : PostEffectsBase 
{

	public Shader gaussianBlurShader;
	private Material gaussianBlurMaterial = null;

	public Material material 
	{  
		get 
		{
			gaussianBlurMaterial = CheckShaderAndCreateMaterial
				(gaussianBlurShader, gaussianBlurMaterial);
			return gaussianBlurMaterial;
		}  
	}

	// Blur iterations: large figure make more blur.
	[Range(0, 4)]
	public int iterations = 3;
	
	// Blur spread for each iteration - larger value means more blur
	[Range(0.2f, 3.0f)]
	public float blurSpread = 0.6f;
	
	[Range(1, 8)]
	public int downSample = 2;

	// VersionA: simple apply GaussianBlur	/////////////////////////////////////////
	/* 
	void OnRenderImage(RenderTexture src, RenderTexture dest) 
	{
		if (material != null) 
		{
			int rtW = src.width;
			int rtH = src.height;
			RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);

			// vertical pass
			Graphics.Blit(src, buffer, material, 0);
			// horizontal pass
			Graphics.Blit(buffer, dest, material, 1);

			RenderTexture.ReleaseTemporary(buffer);
		} 
		else 
		{
			Graphics.Blit(src, dest);
		}
	} 
	*/
	// VersionB: scale render texture to reduce payload ///////////////////////////////
	/* 
	void OnRenderImage (RenderTexture src, RenderTexture dest) 
	{
		if (material != null) 
		{
			int rtW = src.width/downSample;
			int rtH = src.height/downSample;
			RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
			buffer.filterMode = FilterMode.Bilinear;

			// vertical pass
			Graphics.Blit(src, buffer, material, 0);
			// horizontal pass
			Graphics.Blit(buffer, dest, material, 1);

			RenderTexture.ReleaseTemporary(buffer);
		} 
		else 
		{
			Graphics.Blit(src, dest);
		}
	}
	 */
	/// VersionC: using iterations as larger blur
	void OnRenderImage (RenderTexture src, RenderTexture dest) 
	{
		if (material != null) 
		{
			int rtW = src.width/downSample;
			int rtH = src.height/downSample;

			RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
			buffer0.filterMode = FilterMode.Bilinear;
			Graphics.Blit(src, buffer0);

			for (int i = 0; i < iterations; i++) 
			{
				material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
				RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

				//  vertical pass
				Graphics.Blit(buffer0, buffer1, material, 0);
				RenderTexture.ReleaseTemporary(buffer0);
				buffer0 = buffer1;

				buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

				//  horizontal pass
				Graphics.Blit(buffer0, buffer1, material, 1);
				RenderTexture.ReleaseTemporary(buffer0);
				buffer0 = buffer1;
			}
			Graphics.Blit(buffer0, dest);
			RenderTexture.ReleaseTemporary(buffer0);
		} 
		else 
		{
			Graphics.Blit(src, dest);
		}
	}
}
