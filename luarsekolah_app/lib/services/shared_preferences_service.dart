import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/class_model.dart';
import 'dart:convert';

class SharedPreferencesService {
  // Keys
  static const String _keyFullName = 'fullName';
  static const String _keyBirthDate = 'birthDate';
  static const String _keyGender = 'gender';
  static const String _keyJobStatus = 'jobStatus';
  static const String _keyAddress = 'address';
  static const String _keyProfileImage = 'profileImage';

  static const String _keyClasses = 'classes';

  // Get SharedPreferences instance
  static Future<SharedPreferences> get _instance async =>
      await SharedPreferences.getInstance();

  
  // Save a class
  static Future<bool> saveClass(ClassModel classModel) async {
    try {
      final prefs = await _instance;
      
      // Get existing classes
      final classes = await getAllClasses();
      
      // Check if class already exists (update) or add new
      final existingIndex = classes.indexWhere((c) => c.id == classModel.id);
      
      if (existingIndex >= 0) {
        // Update existing class
        classes[existingIndex] = classModel;
      } else {
        // Add new class
        classes.add(classModel);
      }
      
      // Convert to JSON list
      final jsonList = classes.map((c) => c.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      return await prefs.setString(_keyClasses, jsonString);
    } catch (e) {
      print('Error saving class: $e');
      return false;
    }
  }

  // Get all classes
  static Future<List<ClassModel>> getAllClasses() async {
    try {
      final prefs = await _instance;
      final jsonString = prefs.getString(_keyClasses);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((json) => ClassModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading classes: $e');
      return [];
    }
  }

  // Get a specific class by ID
  static Future<ClassModel?> getClassById(String id) async {
    try {
      final classes = await getAllClasses();
      return classes.firstWhere(
        (c) => c.id == id,
        orElse: () => ClassModel.empty(),
      );
    } catch (e) {
      print('Error getting class by id: $e');
      return null;
    }
  }

  // Delete a class
  static Future<bool> deleteClass(String id) async {
    try {
      final prefs = await _instance;
      
      // Get existing classes
      final classes = await getAllClasses();
      
      // Remove the class with matching id
      classes.removeWhere((c) => c.id == id);
      
      // Convert to JSON list
      final jsonList = classes.map((c) => c.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      return await prefs.setString(_keyClasses, jsonString);
    } catch (e) {
      print('Error deleting class: $e');
      return false;
    }
  }

  // Clear all classes
  static Future<bool> clearAllClasses() async {
    try {
      final prefs = await _instance;
      return await prefs.remove(_keyClasses);
    } catch (e) {
      print('Error clearing classes: $e');
      return false;
    }
  }

  // Check if classes exist
  static Future<bool> hasClasses() async {
    try {
      final classes = await getAllClasses();
      return classes.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get classes by category
  static Future<List<ClassModel>> getClassesByCategory(String category) async {
    try {
      final classes = await getAllClasses();
      return classes.where((c) => c.category == category).toList();
    } catch (e) {
      print('Error getting classes by category: $e');
      return [];
    }
  }

  // Save complete user profile
  static Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await _instance;
      
      await prefs.setString(_keyFullName, profile.fullName);
      
      if (profile.birthDate != null) {
        await prefs.setString(_keyBirthDate, profile.birthDate!);
      }
      
      if (profile.gender != null) {
        await prefs.setString(_keyGender, profile.gender!);
      }
      
      if (profile.jobStatus != null) {
        await prefs.setString(_keyJobStatus, profile.jobStatus!);
      }
      
      if (profile.address != null) {
        await prefs.setString(_keyAddress, profile.address!);
      }
      
      if (profile.profileImage != null) {
        await prefs.setString(_keyProfileImage, profile.profileImage!);
      }
      
      return true;
    } catch (e) {
      print('Error saving profile: $e');
      return false;
    }
  }

  // Get user profile
  static Future<UserProfile> getUserProfile() async {
    try {
      final prefs = await _instance;
      
      return UserProfile(
        fullName: prefs.getString(_keyFullName) ?? '',
        birthDate: prefs.getString(_keyBirthDate),
        gender: prefs.getString(_keyGender),
        jobStatus: prefs.getString(_keyJobStatus),
        address: prefs.getString(_keyAddress),
        profileImage: prefs.getString(_keyProfileImage),
      );
    } catch (e) {
      print('Error loading profile: $e');
      return UserProfile.empty();
    }
  }

  // Save individual field
  static Future<bool> saveField(String key, String value) async {
    try {
      final prefs = await _instance;
      await prefs.setString(key, value);
      return true;
    } catch (e) {
      print('Error saving field: $e');
      return false;
    }
  }

  // Get individual field
  static Future<String?> getField(String key) async {
    try {
      final prefs = await _instance;
      return prefs.getString(key);
    } catch (e) {
      print('Error getting field: $e');
      return null;
    }
  }

  // Remove specific field
  static Future<bool> removeField(String key) async {
    try {
      final prefs = await _instance;
      await prefs.remove(key);
      return true;
    } catch (e) {
      print('Error removing field: $e');
      return false;
    }
  }

  // Clear all user data
  static Future<bool> clearUserData() async {
    try {
      final prefs = await _instance;
      await prefs.remove(_keyFullName);
      await prefs.remove(_keyBirthDate);
      await prefs.remove(_keyGender);
      await prefs.remove(_keyJobStatus);
      await prefs.remove(_keyAddress);
      await prefs.remove(_keyProfileImage);
      return true;
    } catch (e) {
      print('Error clearing user data: $e');
      return false;
    }
  }

  // Check if user profile exists
  static Future<bool> hasUserProfile() async {
    try {
      final prefs = await _instance;
      return prefs.containsKey(_keyFullName);
    } catch (e) {
      return false;
    }
  }
}


