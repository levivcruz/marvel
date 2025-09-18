import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:marvel/services/services.dart';
import 'package:marvel/features/characters/domain/domain.dart';
import 'package:marvel/features/characters/presentation/presentation.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<dynamic> {}

class MockAnalytics extends Mock implements AnalyticsServiceInterface {}

class MockGetCharacters extends Mock implements GetCharacters {}

class MockGetFeatured extends Mock implements GetFeaturedCharacters {}

class MockSearchByName extends Mock
    implements SearchCharactersByNameStartsWith {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockCharacterBloc extends Mock implements CharacterBloc {}

class FakeCharacterEvent extends Fake implements CharacterEvent {}
