import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/domain/entites/certificate.dart';

abstract class CertificateRepository {
  Future<Either<Failure, void>> insertCertificateWithImage(
      CertificateEntity certificate, File image);
  Future<Either<Failure, List<CertificateEntity>>> fetchCertificates(String craftsmanId);
  Future<Either<Failure, void>> deleteCertificate(int certificateId);
}
