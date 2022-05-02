extends MeshInstance3D

var golden_ratio : float = (1 + sqrt(5)) / 2

const X= 0.525731112119133606
const Z= 0.850650808352039932
const N= 0.0

#generates an icosphere
func _ready() -> void:
	var arr : Array = []
	arr.resize(Mesh.ARRAY_MAX)
	
	var verts : Array[Vector3]= [Vector3(-X,N,Z), Vector3(X,N,Z), Vector3(-X,N,-Z), Vector3(X,N,-Z),
		Vector3(N,Z,X), Vector3(N,Z,-X), Vector3(N,-Z,X), Vector3(N,-Z,-X),
		Vector3(Z,X,N), Vector3(-Z,X,N), Vector3(Z,-X,N), Vector3(-Z,-X,N)]
	var uvs : Array[Vector2] = []
	var normals : Array[Vector3] = []
	var indices : Array[int] = [
		0,4,1,
		0,9,4,
		9,5,4,
		4,5,8,
		4,8,1,
		8,10,1,
		8,3,10,
		5,3,8,
		5,2,3,
		2,7,3,
		7,10,3,
		7,6,10,
		7,11,6,
		11,0,6,
		0,1,6,
		6,1,10,
		9,0,11,
		9,11,2,
		9,2,5,
		7,2,11]
	
	for vert in verts:
		normals.append(vert.normalized())
	
	arr[Mesh.ARRAY_VERTEX] = verts
#	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	

func get_middle(v1 : Vector3, v2 : Vector3) -> Vector3:
	var temp : Vector3 = (v2 - v1) * 0.5 + v1
	
	temp = temp.normalized()
	temp *= sqrt(golden_ratio * golden_ratio + 1);
	
	return temp
