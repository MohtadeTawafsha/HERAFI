import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/data/remotDataSource/certificateRemotDataSource.dart';
import 'package:herafi/domain/entites/certificate.dart';
import 'package:herafi/domain/repositories/certificateRepository.dart';

class CertificateRepositoryImpl implements CertificateRepository {
  final CertificateRemoteDataSource remoteDataSource;

  CertificateRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> insertCertificateWithImage(CertificateEntity certificate, File image) async {
    try {
      await remoteDataSource.insertCertificateWithImage(certificate, image);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CertificateEntity>>> fetchCertificates(
      String craftsmanId) async {
    try {
      final certificates = await remoteDataSource.fetchCertificates(craftsmanId);
      return Right(certificates);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCertificate(int certificateId) async {
    try {
      await remoteDataSource.deleteCertificate(certificateId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
