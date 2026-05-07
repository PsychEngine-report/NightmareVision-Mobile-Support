package mobile.backend;

import lime.app.Application;
import haxe.io.Path;
import haxe.io.Bytes;
import openfl.utils.ByteArray;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/** * @Authors StarNova (Cream.BR), LumiCoder (FNF BR)
 * @version 0.1.6 - iOS Compatible
 */
class StorageSystem
{
	private static var folderName(get, never):String;
	
	private static function get_folderName():String
	{
		return Application.current.meta.get('file');
	}
	
	/**
	 * Returns the base storage directory path.
	 * On iOS, we use the Documents directory which is backed up by iCloud by default.
	 */
	public static inline function getStorageDirectory():String
	{
		#if android
		return Path.addTrailingSlash(Environment.getExternalStorageDirectory() + '/.' + folderName);
		#elseif ios
		// iOS apps are sandboxed. documentsDirectory is the standard place for user data.
		return Path.addTrailingSlash(lime.system.System.documentsDirectory);
		#else
		return Path.addTrailingSlash(Sys.getCwd());
		#end
	}
	
	public static function getDirectory():String
	{
		return getStorageDirectory();
	}
	
	/**
	 * Requests permissions and verifies assets.
	 */
	public static function getPermissions():Void
	{
		#if android
		if (VERSION.SDK_INT >= VERSION_CODES.TIRAMISU)
		{
			Permissions.requestPermissions(['READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO']);
		}
		else
		{
			Permissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
		}
		
		if (VERSION.SDK_INT >= VERSION_CODES.R)
		{
			if (!Environment.isExternalStorageManager()) Settings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}
		#elseif ios
		// iOS permissions for local file writing in the sandbox are granted by default.
		// You only need to prompt if accessing the Photo Gallery or Camera.
		#end

		setupFilesystem();
	}

	private static function setupFilesystem():Void
	{
		try
		{
			var path = getDirectory();
			if (!FileSystem.exists(path)) FileSystem.createDirectory(path);
			
			// Check if assets need extraction
			if (!FileSystem.exists(path + "assets"))
			{
				startAssetExtraction();
			}
		}
		catch (e:Dynamic)
		{
			trace("Storage Error: " + e);
		}
	}
	
	private static function startAssetExtraction():Void
	{
		#if mobile
		// Generic mobile popup helper (ensure your PopUp class is cross-platform)
		PopUp.showAlert("Extracting Files", "Setting up assets for first-time use. Please wait.", "OK");
		
		try
		{
			copyFromAssets("assets/");
			copyFromAssets("content/");
			
			PopUp.showConfirm("Success!", "Files extracted. The game will now restart.", "Restart", "Cancel", function() {
				lime.system.System.exit(0);
			});
		}
		catch (e:Dynamic)
		{
			trace("Extraction Error: " + e);
		}
		#end
	}
	
	#if sys
	public static function saveContent(name:String = 'file', ext:String = '.json', data:String = ''):Void
	{
		var saveFolder:String = Path.join([getDirectory(), "files"]);
		var fullPath:String = Path.join([saveFolder, name + ext]);
		
		try
		{
			if (!FileSystem.exists(saveFolder)) createDirectoryRecursive(saveFolder);
			
			File.saveContent(fullPath, data);
			// Removing the popup on every save is usually better for UX, 
			// but kept here to match your original logic.
			PopUp.showAlert("Success!", "File saved successfully.", "OK");
		}
		catch (e:haxe.Exception)
		{
			trace('Error saving: ' + e.message);
			PopUp.showAlert("Error", "Could not save file.", "Close");
		}
	}
	#end

	/**
	 * Renamed from copyFromAPK to copyFromAssets to be platform neutral.
	 */
	public static function copyFromAssets(sourceDir:String, targetDir:String = null, forceOverwrite:Bool = true):Void
	{
		#if mobile
		if (!StringTools.endsWith(sourceDir, "/")) sourceDir += "/";
		
		var baseDirectory = getDirectory();
		if (targetDir == null) targetDir = baseDirectory + sourceDir;
		if (!StringTools.endsWith(targetDir, "/")) targetDir += "/";
		
		try
		{
			var assetList:Array<String> = Assets.list();
			var copiedCount = 0;
			
			for (assetPath in assetList)
			{
				if (StringTools.startsWith(assetPath, sourceDir))
				{
					var relativePath = assetPath.substring(sourceDir.length);
					if (relativePath == "" || relativePath == null) continue;
					
					var fullTargetPath = Path.join([targetDir, relativePath]);
					var targetFolder = Path.directory(fullTargetPath);
					
					if (!FileSystem.exists(targetFolder)) createDirectoryRecursive(targetFolder);
					
					if (Assets.exists(assetPath))
					{
						if (FileSystem.exists(fullTargetPath) && !forceOverwrite) continue;
						
						var fileBytes:Bytes = Assets.getBytes(assetPath);
						if (fileBytes != null)
						{
							File.saveBytes(fullTargetPath, fileBytes);
							copiedCount++;
						}
					}
				}
			}
			trace('Extracted $copiedCount files.');
		}
		catch (e:Dynamic)
		{
			trace('Critical Extraction Error: $e');
		}
		#end
	}
	
	private static function createDirectoryRecursive(path:String):Void
	{
		if (FileSystem.exists(path)) return;
		
		var parts = path.split("/");
		var current = "";
		
		// Handle leading slash for absolute paths
		if (path.indexOf("/") == 0) {
			current = "/";
		}

		for (part in parts)
		{
			if (part == "") continue;
			current = Path.join([current, part]);
			if (!FileSystem.exists(current))
			{
				try { FileSystem.createDirectory(current); } catch(e:Dynamic) {}
			}
		}
	}
}package mobile.backend;

import lime.app.Application;
import haxe.io.Path;
import haxe.io.Bytes;
import openfl.utils.ByteArray;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/** * @Authors StarNova (Cream.BR), LumiCoder (FNF BR)
 * @version 0.1.6 - iOS Compatible
 */
class StorageSystem
{
	private static var folderName(get, never):String;
	
	private static function get_folderName():String
	{
		return Application.current.meta.get('file');
	}
	
	/**
	 * Returns the base storage directory path.
	 * On iOS, we use the Documents directory which is backed up by iCloud by default.
	 */
	public static inline function getStorageDirectory():String
	{
		#if android
		return Path.addTrailingSlash(Environment.getExternalStorageDirectory() + '/.' + folderName);
		#elseif ios
		// iOS apps are sandboxed. documentsDirectory is the standard place for user data.
		return Path.addTrailingSlash(lime.system.System.documentsDirectory);
		#else
		return Path.addTrailingSlash(Sys.getCwd());
		#end
	}
	
	public static function getDirectory():String
	{
		return getStorageDirectory();
	}
	
	/**
	 * Requests permissions and verifies assets.
	 */
	public static function getPermissions():Void
	{
		#if android
		if (VERSION.SDK_INT >= VERSION_CODES.TIRAMISU)
		{
			Permissions.requestPermissions(['READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO']);
		}
		else
		{
			Permissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
		}
		
		if (VERSION.SDK_INT >= VERSION_CODES.R)
		{
			if (!Environment.isExternalStorageManager()) Settings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}
		#elseif ios
		// iOS permissions for local file writing in the sandbox are granted by default.
		// You only need to prompt if accessing the Photo Gallery or Camera.
		#end

		setupFilesystem();
	}

	private static function setupFilesystem():Void
	{
		try
		{
			var path = getDirectory();
			if (!FileSystem.exists(path)) FileSystem.createDirectory(path);
			
			// Check if assets need extraction
			if (!FileSystem.exists(path + "assets"))
			{
				startAssetExtraction();
			}
		}
		catch (e:Dynamic)
		{
			trace("Storage Error: " + e);
		}
	}
	
	private static function startAssetExtraction():Void
	{
		#if mobile
		// Generic mobile popup helper (ensure your PopUp class is cross-platform)
		PopUp.showAlert("Extracting Files", "Setting up assets for first-time use. Please wait.", "OK");
		
		try
		{
			copyFromAssets("assets/");
			copyFromAssets("content/");
			
			PopUp.showConfirm("Success!", "Files extracted. The game will now restart.", "Restart", "Cancel", function() {
				lime.system.System.exit(0);
			});
		}
		catch (e:Dynamic)
		{
			trace("Extraction Error: " + e);
		}
		#end
	}
	
	#if sys
	public static function saveContent(name:String = 'file', ext:String = '.json', data:String = ''):Void
	{
		var saveFolder:String = Path.join([getDirectory(), "files"]);
		var fullPath:String = Path.join([saveFolder, name + ext]);
		
		try
		{
			if (!FileSystem.exists(saveFolder)) createDirectoryRecursive(saveFolder);
			
			File.saveContent(fullPath, data);
			// Removing the popup on every save is usually better for UX, 
			// but kept here to match your original logic.
			PopUp.showAlert("Success!", "File saved successfully.", "OK");
		}
		catch (e:haxe.Exception)
		{
			trace('Error saving: ' + e.message);
			PopUp.showAlert("Error", "Could not save file.", "Close");
		}
	}
	#end

	/**
	 * Renamed from copyFromAPK to copyFromAssets to be platform neutral.
	 */
	public static function copyFromAssets(sourceDir:String, targetDir:String = null, forceOverwrite:Bool = true):Void
	{
		#if mobile
		if (!StringTools.endsWith(sourceDir, "/")) sourceDir += "/";
		
		var baseDirectory = getDirectory();
		if (targetDir == null) targetDir = baseDirectory + sourceDir;
		if (!StringTools.endsWith(targetDir, "/")) targetDir += "/";
		
		try
		{
			var assetList:Array<String> = Assets.list();
			var copiedCount = 0;
			
			for (assetPath in assetList)
			{
				if (StringTools.startsWith(assetPath, sourceDir))
				{
					var relativePath = assetPath.substring(sourceDir.length);
					if (relativePath == "" || relativePath == null) continue;
					
					var fullTargetPath = Path.join([targetDir, relativePath]);
					var targetFolder = Path.directory(fullTargetPath);
					
					if (!FileSystem.exists(targetFolder)) createDirectoryRecursive(targetFolder);
					
					if (Assets.exists(assetPath))
					{
						if (FileSystem.exists(fullTargetPath) && !forceOverwrite) continue;
						
						var fileBytes:Bytes = Assets.getBytes(assetPath);
						if (fileBytes != null)
						{
							File.saveBytes(fullTargetPath, fileBytes);
							copiedCount++;
						}
					}
				}
			}
			trace('Extracted $copiedCount files.');
		}
		catch (e:Dynamic)
		{
			trace('Critical Extraction Error: $e');
		}
		#end
	}
	
	private static function createDirectoryRecursive(path:String):Void
	{
		if (FileSystem.exists(path)) return;
		
		var parts = path.split("/");
		var current = "";
		
		// Handle leading slash for absolute paths
		if (path.indexOf("/") == 0) {
			current = "/";
		}

		for (part in parts)
		{
			if (part == "") continue;
			current = Path.join([current, part]);
			if (!FileSystem.exists(current))
			{
				try { FileSystem.createDirectory(current); } catch(e:Dynamic) {}
			}
		}
	}
}
