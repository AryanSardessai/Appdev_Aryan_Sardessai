// Suppress the Firebase warnings during tests
jest.mock('firebase/app', () => ({
  initializeApp: jest.fn(() => ({
    name: '[DEFAULT]',
  })),
}));

jest.mock('firebase/firestore', () => ({
  getFirestore: jest.fn(() => ({
    type: 'firestore',
  })),
}));

describe('Firebase Configuration Module', () => {
  describe('Module structure', () => {
    it('should be able to import the firebaseConfig module', () => {
      expect(() => {
        require('./firebaseConfig');
      }).not.toThrow();
    });

    it('should export a db object', () => {
      const firebaseModule = require('./firebaseConfig');
      expect(firebaseModule).toHaveProperty('db');
    });

    it('should only export the db instance for security', () => {
      const firebaseModule = require('./firebaseConfig');
      const keys = Object.keys(firebaseModule).filter(k => !k.startsWith('__'));
      expect(keys).toEqual(['db']);
    });
  });

  describe('Security best practices', () => {
    it('should not expose the raw firebaseConfig object', () => {
      const firebaseModule = require('./firebaseConfig');
      expect(firebaseModule.firebaseConfig).toBeUndefined();
    });

    it('should not expose the Firebase app instance', () => {
      const firebaseModule = require('./firebaseConfig');
      expect(firebaseModule.app).toBeUndefined();
    });

    it('should not expose API keys in exports', () => {
      const firebaseModule = require('./firebaseConfig');
      const dbString = JSON.stringify(firebaseModule.db);
      // API keys should not be directly accessible through exports
      expect(dbString).not.toContain('AIzaSy');
    });
  });

  describe('Integration with Firebase', () => {
    it('module loads without errors when Firebase is initialized', () => {
      // If the module loads, Firebase initialization succeeded
      const firebaseModule = require('./firebaseConfig');
      expect(firebaseModule.db).toBeDefined();
    });

    it('should have a properly typed Firestore instance', () => {
      const firebaseModule = require('./firebaseConfig');
      expect(typeof firebaseModule.db).toBe('object');
      expect(firebaseModule.db).not.toBeNull();
    });
  });
});
