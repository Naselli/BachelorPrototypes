using System ;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class USBSimpleColorController : MonoBehaviour {
    public  ComputeShader m_shader ;
    public  RenderTexture m_mainTex ;
    private int           m_texSize = 256 ;
    private Renderer      m_rend ;

    private void Start ( ) {
        m_mainTex = new RenderTexture ( m_texSize , m_texSize , 0 , RenderTextureFormat.ARGB32 ) ;
        m_mainTex.enableRandomWrite = true ;
        m_mainTex.Create ( ) ;
        
        //get material's rander component
        m_rend = GetComponent < Renderer > ( ) ;
        //make object visible
        m_rend.enabled = true ;
        
        //send textue to the Compute Shader
        m_shader.SetTexture ( 0 , "Result" , m_mainTex ) ;
        //send texture to the Quad's material
        m_rend.material.SetTexture ( "_MainTex" , m_mainTex ) ;
        //generate the threads group to process the texture
        m_shader.Dispatch ( 0 , m_texSize / 8 , m_texSize / 8 , 1 ) ;
        
    }
    
}
