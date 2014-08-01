--常用函数定义--

--输出日志--
function log(str)
    Debug.Log(str);
end

--打印字符串--
function print(str) 
	Debug.Log(str);
end

--错误日志--
function error(str) 
	Debug.LogError(str);
end

--警告日志--
function warn(str) 
	Debug.LogWarning(str);
end

--查找对象--
function find(str)
	return GameObject.Find(str);
end

function destroy(obj)
	GameObject.Destroy(obj);
end

function instantiate(prefab)
	return GameObject.Instantiate(prefab);
end

function child(str)
	return transform:FindChild(str);
end

function subGet(childNode, typeName)		
	return child(childNode):GetComponent(typeName);
end

function findPanel(str) 
	local obj = find(str);
	if obj == nil then
		error(str.." is null");
		return nil;
	end
	return obj:GetComponent("BaseLua");
end