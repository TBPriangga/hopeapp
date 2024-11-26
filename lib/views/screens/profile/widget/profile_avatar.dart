import 'dart:io';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final bool isLocalImage;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.radius = 40,
    this.isLocalImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      child: _buildAvatarContent(),
    );
  }

  Widget _buildAvatarContent() {
    if (photoUrl == null) {
      return Icon(
        Icons.person,
        size: radius * 0.8,
        color: Colors.grey[400],
      );
    }

    if (isLocalImage) {
      return ClipOval(
        child: Image.file(
          File(photoUrl!),
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: radius * 0.8,
              color: Colors.grey[400],
            );
          },
        ),
      );
    }

    if (photoUrl!.startsWith('assets/')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(photoUrl!),
      );
    }

    return ClipOval(
      child: Image(
        image: NetworkImage(photoUrl!),
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: radius * 0.8,
            color: Colors.grey[400],
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }
}
