describe('ml_user Role — Data Access Only', () => {
  beforeEach(() => {
    cy.fixture('users').then((users) => {
      cy.visit('/login');
      cy.get('#email').type(users.ml_user.email);
      cy.get('#password').type(users.ml_user.password);
      cy.get('#loginSubmit').click();
      cy.url().should('not.include', '/login');
    });
  });

  it('only Device Data nav item is visible', () => {
    cy.get('#navDevices').should('be.visible');
    cy.get('#navUsers').should('not.exist');
    cy.get('#navAccounts').should('not.exist');
  });

  it('direct navigation to /admin/users redirects away', () => {
    cy.visit('/admin/users');
    cy.url().should('not.include','/admin/users');
  });

  it('Device Data page is accessible', () => {
    cy.get('#navDevices').click();
    cy.url().should('include','/admin/devices');
    cy.get('#deviceIdInput').should('exist');
    cy.get('#downloadCsvBtn').should('exist');
    cy.get('#downloadExcelBtn').should('exist');
  });
});
