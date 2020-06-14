package com.coffeebeans.creditum.state;

import com.coffeebeans.creditum.contract.IOUContract;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.common.collect.Lists;
import java.util.Currency;
import java.util.List;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import net.corda.core.contracts.Amount;
import net.corda.core.contracts.BelongsToContract;
import net.corda.core.contracts.ContractState;
import net.corda.core.contracts.LinearState;
import net.corda.core.contracts.UniqueIdentifier;
import net.corda.core.identity.AbstractParty;
import net.corda.core.identity.Party;
import net.corda.core.serialization.ConstructorForDeserialization;
import org.jetbrains.annotations.NotNull;

/**
 * The IOU State object, with the following properties: - [amount] The amount owed by the [borrower] to the [lender] - [lender] The lending party. -
 * [borrower] The borrowing party. - [contract] Holds a reference to the [IOUContract] - [paid] Records how much of the [amount] has been paid. -
 * [linearId] A unique id shared by all LinearState states representing the same agreement throughout history within the vaults of all parties. Verify
 * methods should check that one input and one output share the id in a transaction, except at issuance/termination.
 */

@Getter
@EqualsAndHashCode
@BelongsToContract(IOUContract.class)
public class IOUState implements ContractState, LinearState {

  private final Amount<Currency> amount;
  private final Party lender;
  private final Party borrower;
  private final Amount<Currency> paid;
  private final UniqueIdentifier linearId;

  // Private constructor used only for copying a State object
  @ConstructorForDeserialization
  private IOUState(final Amount<Currency> amount,
      final Party lender,
      final Party borrower,
      final Amount<Currency> paid,
      final UniqueIdentifier linearId) {
    this.amount = amount;
    this.lender = lender;
    this.borrower = borrower;
    this.paid = paid;
    this.linearId = linearId;
  }

  @JsonCreator
  public IOUState(@JsonProperty("amount") final Amount<Currency> amount,
      @JsonProperty("lender") final Party lender,
      @JsonProperty("borrower") final Party borrower) {
    this(amount, lender, borrower, new Amount<>(0, amount.getToken()), new UniqueIdentifier());
  }

  @NotNull
  @Override
  public List<AbstractParty> getParticipants() {
    return Lists.newArrayList(lender, borrower);
  }

  /**
   * Helper methods for when building transactions for settling and transferring IOUs. - [pay] adds an amount to the paid property. It does no
   * validation. - [withNewLender] creates a copy of the current state with a newly specified lender. For use when transferring. - [copy] creates a
   * copy of the state using the internal copy constructor ensuring the LinearId is preserved.
   */
  public IOUState pay(Amount<Currency> amountToPay) {
    Amount<Currency> newAmountPaid = this.paid.plus(amountToPay);
    return new IOUState(amount, lender, borrower, newAmountPaid, linearId);
  }

  public IOUState withNewLender(Party newLender) {
    return new IOUState(amount, newLender, borrower, paid, linearId);
  }

  public IOUState copy(Amount<Currency> amount, Party lender, Party borrower, Amount<Currency> paid) {
    return new IOUState(amount, lender, borrower, paid, this.getLinearId());
  }
}