import './style.css'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import * as Tone from 'tone'




import vertexShader from './shaders/one/vertex.glsl'
import fragmentShader from './shaders/one/fragment.glsl'

let mediaElement
let playing = false
let ready = false
const play = document.getElementById('play')
play.addEventListener('click', function (e) {
  if(!playing && ready){
    sound.play();
    playing = true
    play.style.display = "none";
  }



});

/**
 * Base
 */
// Debug

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()
//scene.background = new THREE.Color( 0xffffff )

/**
 * Textures
 */
const textureLoader = new THREE.TextureLoader()
const texture = textureLoader.load('./textures/texture.png')



//geometry
// const geometry =  new THREE.PlaneGeometry( 1, 1, 100, 100 )

// const geometry = new THREE.SphereGeometry(4,128, 128)

const geometry =  new THREE.BoxGeometry( 2, 2, 2, 100, 100, 100 )

//

// Material
const material = new THREE.ShaderMaterial({
  vertexShader: vertexShader,
  fragmentShader: fragmentShader,
  transparent: true,
  depthWrite: false,
  clipShadows: true,
  side: THREE.DoubleSide,
  uniforms: {
    uFrequency: {
      value: [0]
    },
    tAudioData: {
      value: 0
    } ,

    uTime: {
      value: 0
    },
    uColor: {
      value: new THREE.Color('orange')
    },
    uTexture: {
      value: texture
    },
    uMouse: {
      value: {x: 0.5, y: 0.5}
    },
    uResolution: { value: { x: window.innerWidth, y: window.innerHeight} },
    uPosition: {
      value: {
        x: 0
      }
    },
    uRotation: {
      value: {

      }
    }
  }
})


const mesh = new THREE.Mesh(geometry, material)
scene.add(mesh)


window.addEventListener('mousemove', function (e) {
  material.uniforms.uMouse.value.x =  (e.clientX / window.innerWidth) * 2 - 1
  material.uniforms.uMouse.value.y = -(event.clientY / window.innerHeight) * 2 + 1

})



/**
 * Sizes
 */
const sizes = {
  width: window.innerWidth,
  height: window.innerHeight
}

window.addEventListener('resize', () =>{

  //Update uniforms
  if (material.uniforms.u_resolution !== undefined){
    material.uniforms.u_resolution.value.x = window.innerWidth
    material.uniforms.u_resolution.value.y = window.innerHeight
  }
  // Update sizes
  sizes.width = window.innerWidth
  sizes.height = window.innerHeight

  // Update camera
  camera.aspect = sizes.width / sizes.height
  camera.updateProjectionMatrix()

  // Update renderer
  renderer.setSize(sizes.width, sizes.height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 0.1, 100)
camera.position.set(0.0, 0.0, 1.5)
scene.add(camera)


// Controls
// const controls = new OrbitControls(camera, canvas)
// controls.enableDamping = true
/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
  canvas: canvas,
  alpha: true
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
renderer.localClippingEnabled = true
renderer.globalClippingEnabled = true

scene.background = null

const listener = new THREE.AudioListener()
camera.add( listener )

// create a global audio source
const sound = new THREE.Audio( listener )

// load a sound and set it as the Audio object's buffer
const audioLoader = new THREE.AudioLoader()
audioLoader.load( './assets/music/Forever.mp3', function( buffer ) {
  sound.setBuffer( buffer )
  sound.setLoop( false )
  sound.setVolume( 0.5 )
  ready = true
  // sound.play();
})
const analyser = new THREE.AudioAnalyser( sound, 128 )



/**
 * Animate
 */

console.log(mesh)

const clock = new THREE.Clock()

const tick = () =>{
  const elapsedTime = clock.getElapsedTime()
  // console.log(camera)
  //Update Material
  material.uniforms.uTime.value = elapsedTime
  material.uniforms.uPosition.value = mesh.position
  material.uniforms.uRotation.value = mesh.rotation
  //material.uniforms.uFrequency.value = analyser.getValue()
  analyser.getFrequencyData()

  if(analyser.data){
    // console.log(analyser.data)
    material.uniforms.tAudioData.value = 	 new THREE.DataTexture( analyser.data, 128 / 2, 1,  ( renderer.capabilities.isWebGL2 ) ? THREE.RedFormat : THREE.LuminanceFormat )
  }

  // mesh.rotation.z +=0.001
  // Update controls
  // controls.update()
  // mesh.position.copy(camera.position)


  // Render
  renderer.render(scene, camera)


  // console.log(analyser.getValue())

  // Call tick again on the next frame
  window.requestAnimationFrame(tick)
}

tick()
